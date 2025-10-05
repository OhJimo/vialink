# Poplink

> CTA 오버레이를 추가할 수 있는 URL 단축 서비스

Poplink는 링크를 공유할 때 커스텀 CTA(Call-to-Action)를 추가할 수 있는 서비스입니다. [Sniply](https://sniply.io/)의 핵심 기능만 구현한 MVP 프로젝트입니다.

## 주요 기능

- **URL 단축**: 원본 URL을 짧은 코드로 변환
- **CTA 오버레이**: iframe 하단에 커스텀 CTA 추가
- **커스터마이징**: 텍스트, 링크, 위치, 색상 등 자유롭게 설정
- **관리 대시보드**: Motor Admin을 통한 링크 관리

## 기술 스택

### Backend
- **Ruby** 3.4.6
- **Rails** 8.0.3
- **SQLite3** - Database
- **Puma** - Web Server

### Frontend
- **ERB** - View Templates
- **Turbo Rails** - SPA-like Experience
- **Vanilla CSS/JS** - 최소 의존성

### Infrastructure
- **Fly.io** - Deployment Platform
- **Litestream** - SQLite Replication
- **Motor Admin** - Admin Dashboard

## 빠른 시작

### 요구사항

- Ruby 3.4.6
- Rails 8.0.3
- SQLite3

### 설치

```bash
# 저장소 클론
git clone https://github.com/benayou/poplink.git
cd poplink

# 의존성 설치
bundle install

# 데이터베이스 생성
bin/rails db:create db:migrate

# 개발 서버 실행
bin/rails server
```

서버가 [http://localhost:3000](http://localhost:3000)에서 실행됩니다.

### 사용 방법

1. 메인 페이지에서 원본 URL 입력
2. CTA 정보 설정 (텍스트, 링크, 버튼, 색상 등)
3. 생성된 단축 URL 공유
4. 방문자는 원본 콘텐츠와 함께 CTA 확인

## 프로젝트 구조

```
poplink/
├── app/
│   ├── controllers/
│   │   └── links_controller.rb      # 링크 CRUD
│   ├── models/
│   │   ├── concerns/
│   │   │   ├── code_generator.rb    # 코드 생성 로직
│   │   │   └── default_attributes.rb # 기본값 설정
│   │   └── link.rb                  # Link 모델
│   ├── views/links/
│   │   ├── _form.html.erb           # 링크 생성 폼
│   │   ├── new.html.erb             # 메인 페이지
│   │   └── show.html.erb            # 프록시 페이지 (iframe + CTA)
│   └── assets/stylesheets/
│       └── links.css                # 스타일시트
├── config/
│   └── routes.rb                    # 라우팅 설정
└── db/
    ├── migrate/
    └── schema.rb                    # 데이터베이스 스키마
```

## 데이터베이스 스키마

```ruby
create_table "links" do |t|
  t.string "original_url", null: false     # 원본 URL
  t.string "code", null: false             # 단축 코드 (unique)
  t.string "cta_text"                      # CTA 메시지
  t.string "cta_link"                      # CTA 버튼 링크
  t.string "cta_button_text"               # 버튼 텍스트
  t.string "cta_position"                  # 위치 (left/center/right)
  t.string "cta_color"                     # 배경색 (hex)
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["code"], unique: true
end
```

## 라우팅

- `GET /` - 링크 생성 폼
- `POST /links` - 링크 생성
- `GET /:code` - 단축 URL 리다이렉트 (프록시 페이지)
- `GET /motor_admin` - 관리자 대시보드

## 배포

### Fly.io 배포

```bash
# Fly.io CLI 설치
curl -L https://fly.io/install.sh | sh

# 로그인
flyctl auth login

# 앱 생성 (no-deploy 옵션)
flyctl launch --no-deploy

# 환경변수 설정
flyctl secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# 배포
flyctl deploy

# 상태 확인
flyctl status

# 로그 확인
flyctl logs
```

### 환경 변수

- `RAILS_MASTER_KEY` - Rails credentials 암호화 키 (필수)
- `DATABASE_URL` - SQLite 데이터베이스 경로 (기본: `sqlite3:///data/production.sqlite3`)

## 제한사항

### X-Frame-Options 차단

많은 웹사이트들이 `X-Frame-Options: DENY` 헤더를 설정하여 iframe 임베딩을 차단합니다.

**차단되는 사이트 예시:**
- Google, Facebook, YouTube, Twitter 등 대부분의 메이저 사이트

**대응:**
- 차단 시 에러 메시지 표시
- 원본 페이지로 이동하는 링크 제공

### HTTPS 필수

- HTTPS 사이트에서 HTTP iframe은 브라우저가 차단
- 프로덕션 환경에서는 HTTPS 필수

## 개발

### 코드 스타일 검사

```bash
# RuboCop 실행
bin/rubocop

# 자동 수정
bin/rubocop --autocorrect
```

### 테스트

```bash
# 전체 테스트 실행
bin/rails test

# 시스템 테스트 실행
bin/rails test:system
```

### 프로덕션 환경 로컬 테스트

```bash
# Assets 프리컴파일
RAILS_ENV=production rails assets:precompile

# 데이터베이스 생성 및 마이그레이션
RAILS_ENV=production rails db:create db:migrate

# 프로덕션 서버 실행
RAILS_ENV=production rails server -p 3002
```

## 로드맵

### 완료
- ✅ 핵심 기능 구현 (링크 생성, CTA 오버레이)
- ✅ CTA 커스터마이징 (위치, 색상, 텍스트)
- ✅ Fly.io 배포
- ✅ Motor Admin 대시보드

### 진행 중
- 🔄 커스텀 도메인 연결
- 🔄 Analytics (클릭 추적)

### 예정
- ⏳ QR 코드 생성
- ⏳ 사용자 인증 (Devise)
- ⏳ 링크 유효기간 설정
- ⏳ A/B 테스트
- ⏳ API 제공
- ⏳ PostgreSQL 마이그레이션 (트래픽 증가 시)

## 기여

풀 리퀘스트와 이슈는 언제나 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

MIT License - 자유롭게 사용, 수정, 배포할 수 있습니다.

## 문의

프로젝트 관련 문의사항은 GitHub Issues를 이용해주세요.

---

**Built with Ruby on Rails 8** | **Deployed on Fly.io**
