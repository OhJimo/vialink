# Poplink 개발 로그

## 프로젝트 개요
- **프로젝트명**: Poplink
- **목적**: 링크 공유 시 CTA(Call-to-Action)를 추가할 수 있는 서비스
- **영감**: Sniply.io의 핵심 기능만 구현
- **기술 스택**: Ruby on Rails 8.0.3, SQLite, iframe 기반

## 핵심 기능
1. **URL 단축/저장** - 원본 URL + CTA 정보 저장
2. **프록시 페이지** - iframe으로 원본 콘텐츠 표시 + CTA 오버레이
3. **CTA 커스터마이징** - 텍스트, 링크, 위치, 스타일 설정

## 기술적 결정사항

### 1. iframe vs 서버사이드 프록시
**선택**: iframe 방식

**이유**:
- 구현 복잡도가 낮음
- 빠른 MVP 개발 가능
- 서버 부하 적음

**제한사항**:
- X-Frame-Options 차단 문제 (Google, Facebook 등)
- 해결: 차단 시 에러 메시지 표시

### 2. 데이터베이스
**선택**: SQLite

**이유**:
- 초기 서비스에 충분
- 파일 기반으로 백업 간단
- Rails의 ActiveRecord로 나중에 PostgreSQL 전환 용이

**확장 계획**:
- 트래픽 증가 시 PostgreSQL로 마이그레이션

### 3. 배포 전략
**초기**: Fly.io (PaaS)
- 무료 티어로 빠른 검증
- SQLite 지원
- Git push 자동 배포

**성장 시**: Kamal + VPS
- 비용 절감
- 자체 서버 운영

## 프로젝트 구조

### Models
```ruby
# app/models/link.rb
class Link < ApplicationRecord
  include CodeGenerator      # 단축 코드 생성
  include DefaultAttributes  # 기본값 설정

  # Validations
  - original_url (필수, URL 형식)
  - code (필수, unique, 6자리 alphanumeric)
  - cta_text, cta_link, cta_button_text
  - cta_position (left/center/right)
  - cta_color (hex color)
end
```

### Controllers
```ruby
# app/controllers/links_controller.rb
class LinksController < ApplicationController
  def new      # 링크 생성 폼
  def create   # 링크 저장
  def show     # 프록시 페이지 (iframe + CTA)
end
```

### Routes
```ruby
root "links#new"
resources :links, only: [:new, :create, :show]
get "/:code", to: "links#show"  # 단축 URL
```

### Database Schema
```ruby
create_table :links do |t|
  t.string :original_url, null: false    # 원본 URL
  t.string :code, null: false            # 단축 코드 (unique)
  t.string :cta_text                     # CTA 메시지
  t.string :cta_link                     # CTA 버튼 링크
  t.string :cta_button_text              # 버튼 텍스트 (기본: "자세히 보기")
  t.string :cta_position                 # 위치 (기본: "center")
  t.string :cta_color                    # 배경색 (기본: "#2563eb")
  t.timestamps
end

add_index :links, :code, unique: true
```

## 코드 구조 개선 (리팩토링)

### 1. Model Concerns 분리
**CodeGenerator** (`app/models/concerns/code_generator.rb`)
- 6자리 랜덤 코드 생성 로직 분리
- `SecureRandom.alphanumeric(6)` 사용

**DefaultAttributes** (`app/models/concerns/default_attributes.rb`)
- CTA 기본값 설정 로직 분리
- 재사용성 향상

### 2. View 파셜화
**Form Partial** (`app/views/links/_form.html.erb`)
- 폼을 별도 파일로 분리
- 재사용 가능한 구조

### 3. CSS 분리
**Before**: 인라인 스타일
**After**: `app/assets/stylesheets/links.css`
- 유지보수성 향상
- 재사용 가능한 클래스 정의

### 4. Helper 메서드
**LinksHelper** (`app/helpers/links_helper.rb`)
```ruby
def cta_position_class(position)
  # left/center/right → flex-start/center/flex-end
end

def cta_overlay_style(link)
  # CTA 오버레이 동적 스타일 생성
end
```

### 5. 린팅
- RuboCop 실행 및 자동 수정
- 코드 스타일 통일

## 개발 과정

### Phase 1: 초기 설정
- ✅ Ruby 3.4.6 + Rails 8.0.3 설치 확인
- ✅ Rails 프로젝트 생성 (`rails new .`)
- ✅ SQLite 데이터베이스 생성

### Phase 2: 핵심 기능 구현
- ✅ Link 모델 및 마이그레이션 생성
- ✅ LinksController 구현
- ✅ 라우팅 설정
- ✅ 링크 생성 폼 (new.html.erb)
- ✅ 프록시 페이지 (show.html.erb)
  - iframe으로 원본 콘텐츠 표시
  - CTA 오버레이 (하단 고정)
  - JavaScript로 X-Frame-Options 에러 핸들링

### Phase 3: UI/UX 개선
- ✅ 한글 인터페이스 적용
- ✅ 폼 스타일링
- ✅ CTA 커스터마이징 옵션
  - 위치 선택 (왼쪽/가운데/오른쪽)
  - 색상 선택 (color picker)
  - 버튼 텍스트 커스터마이징

### Phase 4: 프로덕션 테스트
- ✅ Assets 프리컴파일
- ✅ 프로덕션 데이터베이스 생성
- ✅ 프로덕션 서버 실행 (포트 3002)
- ✅ SSL 설정 이슈 해결
  - `config.force_ssl = false` (로컬 테스트용)
  - `config.assume_ssl = false`

### Phase 5: 코드 정리 및 리팩토링
- ✅ RuboCop 린팅
- ✅ View 파셜 분리
- ✅ Model Concerns 추가
- ✅ CSS 파일 분리
- ✅ Helper 메서드 작성
- ✅ 백그라운드 프로세스 정리

### Phase 6: 배포 준비
- ✅ 프로젝트명 결정: **Poplink**
- ✅ Git 저장소 초기화
- ✅ 브랜딩 업데이트
- 🔄 GitHub 저장소 연결 (진행 중)
- ⏳ Fly.io 배포 (예정)

## 프로젝트명 선정 과정
1. **초기**: Sniply Clone
2. **후보들**:
   - linkko (링코 - 링크 코리아)
   - snipko (스닙코)
   - framelink (프레임링크)
   - poplink (팝링크)
3. **최종 선택**: **Poplink**
   - 짧고 직관적 (2음절)
   - 기능 설명됨 ("팝업처럼 뜨는 링크")
   - 발음 좋음
   - 도메인 확보 가능성

## 학습 내용

### Rails 8의 새로운 기능
- **Kamal**: 기본 내장 배포 도구 (Docker 기반)
- **Solid Queue**: Active Job 백엔드 (대체: Sidekiq)
- **Solid Cache**: 캐시 저장소 (대체: Redis)
- **Importmap**: JavaScript 관리 (대체: Webpack)
- **Turbo + Stimulus**: 프론트엔드 프레임워크

### 배포 전략 이해
**PaaS (Fly.io, Railway, Render)**
- 장점: 관리 불필요, 빠른 배포
- 단점: 비용 증가 (트래픽 증가 시)

**Kamal + VPS**
- 장점: 비용 절감, 완전한 제어
- 단점: 서버 관리 필요, 초기 설정 복잡

### SQLite의 장단점
**장점**:
- 설정 불필요
- 파일 기반으로 백업 간단
- 소규모 서비스에 충분
- Fly.io에서 완벽 지원

**단점**:
- 동시 쓰기 처리 제한
- 대규모 트래픽에 부적합

**전환 계획**:
- ActiveRecord 덕분에 PostgreSQL 전환 용이
- `database.yml` 설정만 변경하면 됨

## 기술 스택 상세

### Backend
- **Ruby**: 3.4.6
- **Rails**: 8.0.3
- **Database**: SQLite3
- **ORM**: ActiveRecord

### Frontend
- **View Engine**: ERB
- **CSS**: Vanilla CSS (links.css)
- **JavaScript**: Vanilla JS (iframe error handling)
- **Turbo**: Rails 8 기본 (SPA-like 경험)

### Deployment
- **Development**: Puma (port 3001)
- **Production Test**: Puma (port 3002)
- **Planned**: Fly.io

### Development Tools
- **Linter**: RuboCop
- **Version Control**: Git
- **Repository**: GitHub (poplink)

## 파일 구조
```
poplink/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       ├── application.css
│   │       └── links.css          # 링크 관련 스타일
│   ├── controllers/
│   │   └── links_controller.rb    # 링크 CRUD
│   ├── helpers/
│   │   └── links_helper.rb        # View 헬퍼
│   ├── models/
│   │   ├── concerns/
│   │   │   ├── code_generator.rb  # 코드 생성 로직
│   │   │   └── default_attributes.rb # 기본값 설정
│   │   └── link.rb                # Link 모델
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb
│       └── links/
│           ├── _form.html.erb     # 폼 파셜
│           ├── new.html.erb       # 링크 생성 페이지
│           └── show.html.erb      # 프록시 페이지
├── config/
│   ├── routes.rb                  # 라우팅 설정
│   ├── database.yml               # DB 설정
│   ├── deploy.yml                 # Kamal 설정
│   └── environments/
│       ├── development.rb
│       └── production.rb
├── db/
│   ├── migrate/
│   │   └── 20251003075750_create_links.rb
│   └── schema.rb
├── storage/                       # SQLite 데이터베이스 파일
│   ├── development.sqlite3
│   └── production.sqlite3
├── PLAN.md                        # 초기 계획서
├── DEVELOPMENT_LOG.md             # 이 파일
└── README.md
```

## 주요 코드 스니펫

### Link 모델
```ruby
class Link < ApplicationRecord
  include CodeGenerator
  include DefaultAttributes

  validates :original_url, :code, presence: true
  validates :code, uniqueness: true
  validates :original_url, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid URL"
  }
end
```

### 프록시 페이지 핵심 로직
```html
<!-- iframe으로 원본 콘텐츠 표시 -->
<iframe id="content-frame" src="<%= @link.original_url %>"></iframe>

<!-- CTA 오버레이 -->
<div id="cta-overlay" style="<%= cta_overlay_style(@link) %>">
  <div class="cta-content">
    <span class="cta-text"><%= @link.cta_text %></span>
    <a href="<%= @link.cta_link %>" class="cta-button">
      <%= @link.cta_button_text %>
    </a>
  </div>
</div>

<!-- X-Frame-Options 에러 핸들링 -->
<script>
  iframe.addEventListener('error', function() {
    iframe.style.display = 'none';
    errorDiv.style.display = 'block';
  });
</script>
```

### 단축 URL 라우팅
```ruby
# /:code 형태로 접근
get "/:code", to: "links#show", as: :short_link

# 예: localhost:3001/abc123 → Link.find_by(code: 'abc123')
```

## 트러블슈팅

### 1. 프로덕션 환경 CSRF 에러
**문제**: `ActionController::InvalidAuthenticityToken`
```
HTTP Origin header (http://localhost:3002) didn't match
request.base_url (https://localhost:3002)
```

**원인**: 프로덕션 환경이 HTTPS를 강제하는데 HTTP로 접속

**해결**:
```ruby
# config/environments/production.rb
config.assume_ssl = false
config.force_ssl = false
```

### 2. RuboCop 린팅 에러
**문제**: 배열 리터럴 내부 공백 스타일 불일치

**해결**:
```bash
bin/rubocop --autocorrect
```

### 3. Assets 프리컴파일
**문제**: 프로덕션에서 CSS 로드 안됨

**해결**:
```bash
RAILS_ENV=production rails assets:precompile
```

## 다음 단계

### 즉시
1. ✅ GitHub 저장소 생성 및 연결
2. ⏳ 첫 커밋 및 푸시
3. ⏳ Fly.io 배포

### 단기
- [ ] 커스텀 도메인 연결
- [ ] Analytics 추가 (클릭 추적)
- [ ] QR 코드 생성 기능
- [ ] 링크 관리 대시보드

### 중기
- [ ] 사용자 인증 (Devise)
- [ ] 링크 유효기간 설정
- [ ] A/B 테스트 기능
- [ ] CTA 템플릿 여러 개

### 장기
- [ ] PostgreSQL 마이그레이션
- [ ] Kamal로 VPS 배포
- [ ] API 제공
- [ ] 브라우저 확장 프로그램

## 프로젝트 타임라인
- **2025-10-03**: 프로젝트 시작
  - Rails 프로젝트 생성
  - 핵심 기능 구현 (Link 모델, 컨트롤러, 뷰)
  - 프로덕션 테스트
  - 코드 리팩토링
  - 프로젝트명 결정 (Poplink)
  - Git 초기화

## 참고 자료
- [Sniply.io](https://sniply.io/) - 영감 출처
- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Fly.io Rails Guide](https://fly.io/docs/rails/)
- [Kamal Documentation](https://kamal-deploy.org/)

## 배운 점 및 회고

### 기술적 학습
1. **Rails 8의 현대적 접근**
   - Kamal을 통한 배포 민주화
   - Solid 제품군으로 인프라 단순화
   - Importmap으로 JS 번들러 제거

2. **iframe의 한계와 대안**
   - X-Frame-Options의 보안 중요성
   - 서버사이드 프록시의 복잡도
   - 트레이드오프 이해

3. **SQLite의 실용성**
   - 초기 서비스에 충분한 성능
   - 파일 기반의 단순함
   - Rails ActiveRecord의 DB 독립성

### 설계 결정
1. **MVP 우선 접근**
   - 복잡한 기능보다 핵심 가치 구현
   - iframe 방식 선택 (빠른 검증)
   - 나중에 확장 가능한 구조 유지

2. **코드 품질**
   - Concerns로 모델 로직 분리
   - 파셜로 뷰 재사용성 확보
   - CSS 분리로 유지보수성 향상

3. **배포 전략**
   - PaaS로 빠른 검증
   - 성장하면 자체 서버로 이동
   - 비용과 편의성의 균형

### 개선 필요사항
- [ ] 테스트 코드 작성 (RSpec)
- [ ] CI/CD 파이프라인 구축
- [ ] 에러 모니터링 (Sentry)
- [ ] 성능 모니터링 (New Relic / Scout)

## 라이선스
MIT License (예정)

## 기여자
- [@benayou](https://github.com/benayou) - 개발자

---

**마지막 업데이트**: 2025-10-03
**상태**: 개발 완료, 배포 준비 중
