# Vialink 구현 계획서

> SQLite 기반 수익화 가능한 MVP 구현

**작성일**: 2025-10-14
**목표**: 회원 시스템 + 플랜별 제한 + 자동 삭제

---

## 📋 목차

1. [현재 상태](#현재-상태)
2. [요금제 구조](#요금제-구조)
3. [데이터베이스 설계](#데이터베이스-설계)
4. [구현 기능](#구현-기능)
5. [구현 순서](#구현-순서)
6. [예상 시간](#예상-시간)

---

## 🎯 현재 상태

### 있는 기능
- ✅ 링크 생성 (Link 모델)
- ✅ 버튼 커스터마이징 (색상, 위치, 텍스트)
- ✅ Motor Admin (관리자 대시보드)
- ✅ SQLite + Litestream 백업
- ✅ Fly.io 배포 환경

### 없는 기능
- ❌ 회원가입/로그인
- ❌ 사용자별 링크 관리
- ❌ 플랜 구분 (Free/Pro/Lifetime)
- ❌ 링크 생성 제한
- ❌ 자동 삭제 (5일/30일)
- ❌ 통계 기능

### 문제점
```
→ 누구나 무제한 링크 생성 가능
→ 링크가 영원히 삭제 안 됨
→ 수익화 불가능
```

---

## 💎 요금제 구조

### 🆓 Free (무료)
```
✅ 회원가입 필수
✅ 월 10개 링크 생성
✅ 무제한 클릭
✅ 5일 후 자동 삭제 ⏰
✅ 기본 버튼만 (커스터마이징 불가)

❌ "Powered by Vialink" 워터마크
❌ 통계 없음
❌ 버튼 색상/위치 변경 불가
```

### 💎 Pro (₩2,900/월)
```
✅ 월 300개 링크 생성 (하루 10개)
✅ 무제한 클릭
✅ 30일 보관 📅
✅ 완전한 버튼 커스터마이징
✅ 워터마크 제거
✅ 클릭 수 통계
```

### 🚀 Lifetime (₩29,000 일시불)
```
✅ 월 500개 링크 생성
✅ 무제한 클릭
✅ 영구 보관 ♾️
✅ 완전한 커스터마이징
✅ 클릭 수 통계
✅ 우선 지원
⏰ 선착순 100명 한정
```

---

## 🗄️ 데이터베이스 설계

### Users 테이블 (Devise)

```ruby
create_table "users" do |t|
  t.string "email", null: false, unique: true
  t.string "encrypted_password", null: false
  t.integer "plan", default: 0  # enum: free(0), pro(1), lifetime(2)
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false

  # Devise 기본 컬럼들
  t.string "reset_password_token"
  t.datetime "reset_password_sent_at"
  t.datetime "remember_created_at"
end
```

### Links 테이블 (수정)

```ruby
create_table "links" do |t|
  # 기존 컬럼
  t.string "original_url", null: false
  t.string "code", null: false, unique: true
  t.string "cta_text"
  t.string "cta_link"
  t.string "cta_button_text"
  t.string "cta_position"
  t.string "cta_color"

  # 추가 컬럼
  t.references "user", null: false, foreign_key: true
  t.datetime "expires_at"  # nil = 영구
  t.integer "click_count", default: 0

  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false

  t.index ["code"], unique: true
  t.index ["user_id"]
  t.index ["expires_at"]
end
```

### 데이터 크기 예상 (1년 후)

```
Users: 1,280명 × 1KB = 1.3MB
Links: 620,000개 × 1.5KB = 930MB
───────────────────────────
총: ~931MB < 1GB ✅

→ SQLite + 1GB 볼륨으로 충분!
```

---

## 🔧 구현 기능

### 1. 회원 시스템 (Devise)

**기능:**
- 회원가입 (이메일 + 비밀번호)
- 로그인/로그아웃
- 비밀번호 재설정

**구현:**
```ruby
# Gemfile
gem 'devise'

# User 모델
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :links, dependent: :destroy

  enum plan: { free: 0, pro: 1, lifetime: 2 }

  after_initialize :set_default_plan, if: :new_record?

  private

  def set_default_plan
    self.plan ||= :free
  end
end
```

### 2. 플랜별 비즈니스 로직

**User 모델 메서드:**

```ruby
class User < ApplicationRecord
  # 플랜별 월 생성 제한
  def monthly_link_limit
    case plan
    when 'free' then 10
    when 'pro' then 300
    when 'lifetime' then 500
    end
  end

  # 플랜별 링크 만료일
  def link_expiry_days
    case plan
    when 'free' then 5
    when 'pro' then 30
    when 'lifetime' then nil  # 영구
    end
  end

  # 이번 달 생성한 링크 수
  def current_month_links_count
    links.where('created_at >= ?', Time.current.beginning_of_month).count
  end

  # 링크 생성 가능 여부
  def can_create_link?
    current_month_links_count < monthly_link_limit
  end

  # 남은 링크 수
  def remaining_links
    monthly_link_limit - current_month_links_count
  end

  # Free 플랜에서 커스터마이징 불가
  def can_customize?
    !free?
  end
end
```

**Link 모델 메서드:**

```ruby
class Link < ApplicationRecord
  belongs_to :user

  # 만료일 자동 설정
  before_create :set_expires_at

  # 만료 확인
  def expired?
    return false if expires_at.nil?
    expires_at < Time.current
  end

  # 클릭 수 증가
  def increment_clicks!
    increment!(:click_count)
  end

  private

  def set_expires_at
    days = user.link_expiry_days
    self.expires_at = days ? days.days.from_now : nil
  end
end
```

### 3. 컨트롤러 수정

**LinksController:**

```ruby
class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :check_link_limit, only: [:create]
  before_action :check_customization, only: [:create, :update]

  def create
    @link = current_user.links.build(link_params)

    if @link.save
      redirect_to dashboard_path, notice: '링크가 생성되었습니다.'
    else
      render :new
    end
  end

  def show
    @link = Link.find_by!(code: params[:code])

    if @link.expired?
      render :expired
    else
      @link.increment_clicks!
      render :show
    end
  end

  private

  def check_link_limit
    unless current_user.can_create_link?
      redirect_to dashboard_path,
                  alert: "이번 달 링크 생성 한도(#{current_user.monthly_link_limit}개)를 초과했습니다."
    end
  end

  def check_customization
    if current_user.free? && customization_requested?
      params[:link][:cta_color] = nil
      params[:link][:cta_position] = 'center'
    end
  end

  def customization_requested?
    params[:link][:cta_color].present? ||
    params[:link][:cta_position] != 'center'
  end
end
```

### 4. 대시보드

**DashboardController:**

```ruby
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @links = current_user.links.order(created_at: :desc).page(params[:page])
    @stats = {
      total_links: current_user.links.count,
      this_month: current_user.current_month_links_count,
      limit: current_user.monthly_link_limit,
      remaining: current_user.remaining_links,
      total_clicks: current_user.links.sum(:click_count)
    }
  end
end
```

### 5. 자동 삭제 로직

**Rake Task:**

```ruby
# lib/tasks/cleanup.rake
namespace :links do
  desc "Delete expired links"
  task cleanup: :environment do
    deleted_count = Link.where('expires_at < ?', Time.current).delete_all
    puts "Deleted #{deleted_count} expired links at #{Time.current}"
  end
end
```

**Fly.io Cron 설정:**

```toml
# fly.toml
[processes]
  web = "bin/rails server"
  worker = "bin/rake links:cleanup"

[[services]]
  internal_port = 8080
  protocol = "tcp"

  [[services.checks]]
    interval = "10s"
    timeout = "2s"
```

---

## 📅 구현 순서

### Phase 1: 문서화 (완료)
- [x] IMPLEMENTATION_PLAN.md 작성

### Phase 2: 핵심 기능 (4-5시간)

#### Step 1: Devise 설치 (1시간)
```bash
# Gemfile에 devise 추가
bundle add devise

# Devise 설치
rails generate devise:install

# User 모델 생성
rails generate devise User

# plan 컬럼 추가
rails generate migration AddPlanToUsers plan:integer

# 마이그레이션 실행
rails db:migrate
```

#### Step 2: Link-User 연결 (30분)
```bash
# user_id, expires_at, click_count 추가
rails generate migration AddUserAndExpirationToLinks \
  user:references \
  expires_at:datetime \
  click_count:integer

# 마이그레이션 실행
rails db:migrate
```

#### Step 3: 비즈니스 로직 구현 (1.5시간)
- User 모델에 플랜 관련 메서드 추가
- Link 모델에 만료/클릭 메서드 추가
- before_action, callback 설정

#### Step 4: 컨트롤러 수정 (30분)
- LinksController 인증 추가
- 링크 생성 제한 체크
- 만료 링크 처리

#### Step 5: 대시보드 (1.5시간)
- DashboardController 생성
- 대시보드 뷰 작성
- 링크 목록, 통계 표시

#### Step 6: 자동 삭제 (30분)
- Rake task 작성
- 테스트

### Phase 3: 배포 (30분)
- vialink.fly.dev 배포
- 기능 테스트
- 버그 수정

---

## ⏱️ 예상 시간

| 단계 | 작업 | 예상 시간 |
|------|------|-----------|
| 1 | 문서화 | 5분 (완료) |
| 2 | Devise 설치 | 1시간 |
| 3 | Link-User 연결 | 30분 |
| 4 | 비즈니스 로직 | 1.5시간 |
| 5 | 컨트롤러 수정 | 30분 |
| 6 | 대시보드 | 1.5시간 |
| 7 | 자동 삭제 | 30분 |
| 8 | 배포/테스트 | 30분 |
| **총합** | | **5-6시간** |

---

## 🚀 배포 후 테스트 항목

### 회원 시스템
- [ ] 회원가입 성공
- [ ] 로그인 성공
- [ ] 로그아웃 성공

### Free 플랜
- [ ] 월 10개 제한 작동
- [ ] 5일 후 자동 삭제
- [ ] 커스터마이징 불가

### Pro 플랜 (수동 설정)
- [ ] 월 300개 제한
- [ ] 30일 후 삭제
- [ ] 커스터마이징 가능

### Lifetime 플랜 (수동 설정)
- [ ] 월 500개 제한
- [ ] 영구 보관
- [ ] 커스터마이징 가능

### 대시보드
- [ ] 내 링크 목록 표시
- [ ] 남은 링크 수 표시
- [ ] 클릭 수 표시

---

## 📝 나중에 추가할 기능

### Phase 4: 결제 연동 (나중에)
- Stripe 연동
- 구독 관리
- 결제 페이지

### Phase 5: 고급 통계 (나중에)
- 일별 클릭 수
- 국가별 통계
- 디바이스별 통계
- CSV 내보내기

### Phase 6: 추가 기능 (나중에)
- 커스텀 도메인
- QR 코드 생성
- A/B 테스트
- API 제공

---

## 🔒 보안 고려사항

### 인증
- Devise의 기본 보안 설정 사용
- HTTPS 강제 (Fly.io)
- Session 관리

### Rate Limiting
- 링크 생성 제한 (플랜별)
- IP 기반 제한 (추후 추가 고려)

### 데이터 보호
- Litestream 자동 백업
- 마스터 키 환경 변수 관리

---

## 💾 SQLite 충분성 분석

### 1년 후 예상 데이터
```
사용자: 1,280명
링크: 620,000개
데이터 크기: ~931MB
```

### SQLite 성능
```
읽기: 초당 수만~수십만 쿼리
쓰기: 초당 수천 쿼리
→ 충분히 가능! ✅
```

### 언제 PostgreSQL로?
- MAU 5,000명 이상
- 동시 접속 폭증
- SQLite 병목 발생 시

---

**작성자**: Claude + benayou
**최종 업데이트**: 2025-10-14
