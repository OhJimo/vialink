# Vialink

> 버튼 오버레이를 추가할 수 있는 URL 단축 서비스

링크를 공유할 때 나만의 홍보 버튼을 추가할 수 있는 서비스입니다.

**배포 URL**: https://vialink.fly.dev

---

## 빠른 시작

### 요구사항

- Ruby 3.4.6
- Rails 8.0.3
- SQLite3

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/benayou/vialink.git
cd vialink

# 의존성 설치
bundle install

# 데이터베이스 생성
bin/rails db:create db:migrate

# 개발 서버 실행
bin/rails server
```

서버가 http://localhost:3000에서 실행됩니다.

---

## 기술 스택

- **Backend**: Ruby 3.4.6 + Rails 8.0.3 + SQLite3
- **Frontend**: ERB + Turbo Rails + Vanilla CSS/JS
- **Infrastructure**: Fly.io + Litestream + Motor Admin
- **비용**: 월 $0.25 (₩325)

---

## 주요 기능

- URL 단축 및 버튼 오버레이
- 사용자 인증 (Devise)
- 플랜별 제한 (Free/Pro/Lifetime)
- 대시보드 및 통계
- 자동 링크 삭제

---

## 배포

```bash
# Fly.io CLI 설치
curl -L https://fly.io/install.sh | sh

# 로그인
flyctl auth login

# 환경변수 설정
flyctl secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# 배포
flyctl deploy
```

---

## 문서

상세한 프로젝트 정보는 [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)를 참조하세요.

---

**Built with Ruby on Rails 8** | **Deployed on Fly.io**
