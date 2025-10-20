# Vialink 프로젝트 개요

> 버튼 오버레이를 추가할 수 있는 URL 단축 서비스

**최종 업데이트**: 2025-10-20
**배포 URL**: https://vialink.fly.dev
**상태**: ✅ 프로덕션 배포 완료

---

## 📋 목차

1. [프로젝트 소개](#프로젝트-소개)
2. [기술 스택](#기술-스택)
3. [핵심 기능](#핵심-기능)
4. [비즈니스 모델](#비즈니스-모델)
5. [현재 구현 상태](#현재-구현-상태)
6. [향후 계획](#향후-계획)

---

## 🎯 프로젝트 소개

### 핵심 가치 제안

**Vialink** = URL 단축 + 버튼 오버레이 + 심플한 수익화

링크를 공유할 때 나만의 홍보 버튼을 추가할 수 있는 서비스입니다. [Sniply](https://sniply.io/)의 핵심 기능만 구현한 MVP입니다.

```
사용자 혜택:
✅ 링크 공유 시 자신의 홍보 버튼 추가 가능
✅ 무료 플랜 제공 (월 10개 링크)
✅ 간단한 브랜딩 & 마케팅 도구
✅ 클릭 추적 및 통계 (유료)

Vialink 차별점:
💰 Sniply 대비 92% 저렴 ($29/월 → ₩2,900/월)
🎯 심플한 UX (복잡한 기능 제거)
⚡ 빠른 배포 (Fly.io, 월 $0.25)
```

### 경쟁 분석

| 서비스 | 기능 | 가격 | Vialink |
|--------|------|------|---------|
| **Sniply** | URL 단축 + CTA | $29/월 | ₩2,900/월 (92% ↓) |
| **Bitly** | URL 단축만 | $8-29/월 | 버튼 포함 |
| **Vialink** | URL 단축 + CTA | ₩2,900/월 | 한국 시장 타겟 |

---

## 🛠️ 기술 스택

### Backend
- **Ruby** 3.4.6 + **Rails** 8.0.3
- **SQLite3** - 가볍고 빠른 데이터베이스
- **Devise** - 사용자 인증
- **Puma** - 웹 서버

### Frontend
- **ERB** - View Templates
- **Turbo Rails** - SPA-like Experience
- **Vanilla CSS/JS** - Supabase + shadcn/ui 디자인
- **Responsive Design** - 모바일 최적화

### Infrastructure
- **Fly.io** - 배포 플랫폼 (싱가포르 리전)
- **Litestream** - SQLite 실시간 백업
- **Motor Admin** - 관리자 대시보드
- **월 비용**: 약 $0.25 (₩325)

### 비용 최적화 전략
```
✅ 256MB Shared CPU (최소 사양)
✅ Auto-stop 활성화 (트래픽 없을 때 자동 중지)
✅ 헬스체크 제거 (비용 절감)
✅ 1GB Volume ($0.15/월)
✅ SQLite 사용 (별도 DB 서버 불필요)

Trade-off: 첫 방문 시 2-5초 cold start
```

---

## 💎 핵심 기능

### 1. URL 단축 및 버튼 오버레이

```
사용자 플로우:
1. 원본 URL 입력 (예: https://example.com/article)
2. 버튼 정보 설정
   - 텍스트: "무료 체험하기"
   - 링크: https://myservice.com
   - 위치: left/center/right
   - 색상: 커스텀 hex 코드
3. 단축 URL 생성 (예: vialink.fly.dev/AbC123)
4. 공유 → 방문자는 원본 콘텐츠 + 홍보 버튼 확인
```

### 2. 플랜별 기능 차별화

#### 🆓 Free (무료)
```
✅ 회원가입 필수
✅ 월 10개 링크 생성
✅ 무제한 클릭
✅ 5일 후 자동 삭제 ⏰
✅ 기본 버튼만

❌ "Powered by Vialink" 워터마크
❌ 통계 없음
❌ 커스터마이징 불가
```

#### 💎 Pro (₩2,900/월)
```
✅ 월 300개 링크 생성
✅ 30일 보관
✅ 완전한 커스터마이징
✅ 워터마크 제거
✅ 클릭 통계 + CSV 내보내기
```

#### 🚀 Lifetime (₩29,000 일시불)
```
✅ 월 500개 링크
✅ 영구 보관 ♾️
✅ 모든 Pro 기능
✅ 우선 지원
⏰ 선착순 100명 한정
```

### 3. 대시보드 및 통계

```
📊 대시보드 기능:
- 내 링크 목록 (생성일, 만료일, 클릭수)
- 이번 달 생성/남은 링크 수
- 총 클릭 수 집계
- 링크 활성화/비활성화
- CSV 내보내기 (Pro+)
```

---

## 💰 비즈니스 모델

### 수익 시뮬레이션

#### 시나리오 1: 초기 (3개월)
```
사용자:
- Free: 100명
- Pro: 8명 (전환율 8%)
- Lifetime: 15명 (전환율 15%)

월 수익:
- Pro: 8 × ₩2,900 = ₩23,200
- Lifetime: 15 × ₩29,000 = ₩435,000
────────────────────────
첫 달 총수익: ₩458,200

비용:
- Fly.io: ₩325
- 도메인: ₩1,250
- 결제 수수료: ₩25,000
────────────────────────
총 비용: ₩26,575

첫 달 순이익: ₩431,625
```

#### 시나리오 2: 안정기 (1년)
```
사용자:
- Free: 1,200명
- Pro: 80명
- Lifetime: 100명 (완판)

월 정기 수익 (MRR):
- Pro: 80 × ₩2,900 = ₩232,000
- 광고 추가: ₩100,000
────────────────────────
MRR: ₩332,000

누적 Lifetime 수익: ₩2,900,000
```

### 핵심 지표 (KPI)

```
사용자 지표:
- MAU: Monthly Active Users
- 회원가입 전환율: 30%
- 유료 전환율: 5-8%
- Churn Rate: <10%

수익 지표:
- MRR: Monthly Recurring Revenue
- ARPU: ₩500-1,000
- LTV: 6개월 × ARPU

제품 지표:
- 월 링크 생성 수
- 평균 링크당 클릭 수
- CTA 클릭률 (CTR)
```

---

## ✅ 현재 구현 상태

### 완료된 기능 (2025-10-20 기준)

#### Phase 1: 핵심 MVP ✅
- [x] 링크 생성 및 단축
- [x] CTA 버튼 오버레이 (iframe)
- [x] 버튼 커스터마이징 (색상, 위치, 텍스트)
- [x] 코드 자동 생성 (6자리 영숫자)

#### Phase 2: 사용자 시스템 ✅
- [x] Devise 인증 (회원가입/로그인)
- [x] 플랜 관리 (Free/Pro/Lifetime)
- [x] 게스트 모드 (3개 무료 체험)
- [x] 한국어 UI

#### Phase 3: 대시보드 ✅
- [x] 링크 목록 (정렬, 필터)
- [x] 이번 달 링크 수 표시
- [x] 플랜별 제한 표시
- [x] 링크 활성화/삭제

#### Phase 4: 통계 기능 ✅
- [x] 클릭 수 추적
- [x] 통계 페이지 (Lifetime 전용)
- [x] 총 클릭 수 집계

#### Phase 5: 디자인 ✅
- [x] Supabase 색상 테마 (#6BCC93)
- [x] shadcn/ui 스타일 (sharp borders, minimal shadows)
- [x] 로그인/회원가입 페이지 디자인
- [x] 반응형 디자인

#### Phase 6: 배포 ✅
- [x] Fly.io 배포 (vialink.fly.dev)
- [x] SQLite + Litestream 백업
- [x] Motor Admin 대시보드
- [x] 비용 최적화 (월 $0.25)

### 데이터베이스 스키마

```ruby
# Users
create_table "users" do |t|
  t.string "email", null: false, unique: true
  t.string "encrypted_password", null: false
  t.integer "plan", default: 0  # free(0), pro(1), lifetime(2)
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end

# Links
create_table "links" do |t|
  t.string "original_url", null: false
  t.string "code", null: false, unique: true
  t.string "cta_text"
  t.string "cta_link"
  t.string "cta_button_text"
  t.string "cta_position"
  t.string "cta_color"

  t.references "user", null: false, foreign_key: true
  t.datetime "expires_at"  # nil = 영구
  t.integer "click_count", default: 0
  t.boolean "active", default: true

  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

---

## 🗺️ 향후 계획

### Phase 7: 자동화 (우선순위 높음)
```
⏳ 예정 (1-2주):
- [ ] 링크 자동 삭제 Cron Job
      (Free: 5일, Pro: 30일)
- [ ] 이메일 알림
      (링크 만료 안내, 한도 도달 알림)
- [ ] 월별 링크 생성 수 초기화
```

### Phase 8: 결제 시스템 (2-3주)
```
⏳ 계획:
- [ ] Stripe/Toss Payments 연동
- [ ] 구독 관리 페이지
- [ ] 플랜 업그레이드/다운그레이드
- [ ] 결제 내역 조회
```

### Phase 9: 고급 통계 (1개월)
```
⏳ 계획:
- [ ] 일별 클릭 수 그래프
- [ ] 국가별 통계
- [ ] 디바이스별 통계
- [ ] Referrer 추적
- [ ] CSV 내보내기 개선
```

### Phase 10: 추가 기능 (3-6개월)
```
💡 아이디어:
- [ ] 커스텀 도메인 연결
- [ ] QR 코드 생성
- [ ] A/B 테스트
- [ ] API 제공
- [ ] 템플릿 마켓플레이스
- [ ] 화이트라벨 (B2B)
```

### 마케팅 로드맵
```
Month 3-4: 베타 런칭
- [ ] GeekNews 소개
- [ ] 개발자 커뮤니티 홍보
- [ ] 블로그 포스팅
- [ ] 베타 테스터 50명 모집

Month 5-6: 정식 런칭
- [ ] Product Hunt 런칭
- [ ] SEO 최적화
- [ ] 콘텐츠 마케팅

Month 7-12: 성장
- [ ] 파트너십 (마케터 커뮤니티)
- [ ] 인플루언서 협업
- [ ] 광고 캠페인 (MAU 1,000+ 시)
```

---

## ⚠️ 기술적 제약사항

### X-Frame-Options 문제

**현실:**
대부분의 주요 웹사이트가 `X-Frame-Options: DENY` 헤더로 iframe 임베딩을 차단합니다.

**차단되는 사이트:**
- Google, Facebook, YouTube, Twitter
- 대부분의 뉴스 사이트 (Naver, Daum)
- 금융 사이트, E-commerce

**작동하는 사이트:**
- 개인 블로그 (WordPress, Tistory)
- 중소형 웹사이트
- 자체 제작 랜딩 페이지

**대응 방안:**
1. 차단 시 명확한 에러 메시지 표시
2. 원본 페이지로 이동 링크 제공
3. 타겟 사용자를 개인 블로거/크리에이터로 명확화

---

## 📊 성공 기준

### 6개월 목표
```
✅ MAU 300명
✅ 유료 전환 20명
✅ MRR ₩100,000
✅ Churn < 15%
```

### 1년 목표
```
✅ MAU 1,000명
✅ 유료 전환 80명
✅ MRR ₩400,000
✅ Churn < 10%
```

---

## 📝 핵심 의사결정

### 1. SQLite vs PostgreSQL?
**결정**: SQLite
**근거**:
- 1년 후 예상 데이터: ~930MB < 1GB
- Litestream으로 실시간 백업
- 별도 DB 서버 비용 절감 (월 ~$7 절약)
- 충분한 성능 (MAU 1,000명 규모)
- 필요시 PostgreSQL 마이그레이션 가능

### 2. iframe vs Redirect?
**결정**: iframe 우선
**근거**:
- UX가 더 자연스러움
- 차단 시 명확한 안내 제공
- 타겟을 개인 블로그/랜딩 페이지로 명확화

### 3. 가격 전략?
**결정**: Pro ₩2,900/월, Lifetime ₩29,000
**근거**:
- Sniply 대비 92% 저렴
- 한국 시장 구매력 고려
- 심리적 가격대 (₩3,000 미만)
- Lifetime으로 초기 자금 확보

---

## 🚀 빠른 시작

### 로컬 개발 환경

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

### Fly.io 배포

```bash
# Fly.io CLI 설치
curl -L https://fly.io/install.sh | sh

# 로그인
flyctl auth login

# 환경변수 설정
flyctl secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# 배포
flyctl deploy

# 상태 확인
flyctl status
```

---

## 📞 문의

- **GitHub**: https://github.com/benayou/vialink
- **이메일**: ben.ayou@hey.com
- **배포 URL**: https://vialink.fly.dev

---

**Built with Ruby on Rails 8** | **Deployed on Fly.io** | **Designed with Supabase + shadcn/ui**

**작성자**: benayou
**최종 업데이트**: 2025-10-20
