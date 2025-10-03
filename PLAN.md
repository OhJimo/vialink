# Sniply Clone - iframe 방식 구현 계획

## 개요
Sniply의 핵심 기능(프레임 + CTA)만 구현하는 최소 기능 프로젝트

## 기술 스택
- Ruby on Rails
- iframe 기반 콘텐츠 표시
- CTA 오버레이

## 핵심 기능

### 1. URL 단축/저장
- 원본 URL 저장
- 고유 단축 코드 생성
- CTA 정보 저장

### 2. 프록시 페이지
- iframe으로 원본 콘텐츠 표시
- CTA 오버레이 (하단 고정)

### 3. CTA 커스터마이징
- 텍스트
- 링크 URL
- 위치 (하단 좌/중/우)
- 스타일 (색상, 버튼 텍스트 등)

## 데이터 모델

### Link 모델
```ruby
# app/models/link.rb
class Link < ApplicationRecord
  # 필드:
  # - original_url:string (원본 URL)
  # - code:string (단축 코드, 예: 'abc123')
  # - cta_text:string (CTA 메시지)
  # - cta_link:string (CTA 버튼 클릭 시 이동할 URL)
  # - cta_button_text:string (CTA 버튼 텍스트)
  # - cta_position:string (left/center/right)
  # - cta_color:string (배경색)

  validates :original_url, :code, presence: true
  validates :code, uniqueness: true

  before_validation :generate_code, on: :create

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(6)
  end
end
```

## 라우팅 구조
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'home#index'

  # Link 생성 API/폼
  resources :links, only: [:new, :create, :show]

  # 단축 URL 접근
  get '/:code', to: 'links#show', as: :short_link
end
```

## 컨트롤러 구조

### LinksController
```ruby
# app/controllers/links_controller.rb
class LinksController < ApplicationController
  def new
    @link = Link.new
  end

  def create
    @link = Link.new(link_params)
    if @link.save
      redirect_to short_link_path(@link.code)
    else
      render :new
    end
  end

  def show
    @link = Link.find_by!(code: params[:code])
    # iframe + CTA 오버레이 렌더링
  end

  private

  def link_params
    params.require(:link).permit(
      :original_url, :cta_text, :cta_link,
      :cta_button_text, :cta_position, :cta_color
    )
  end
end
```

## 뷰 구조

### show.html.erb (프록시 페이지)
```html
<!-- app/views/links/show.html.erb -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body, html {
      margin: 0;
      padding: 0;
      height: 100%;
      overflow: hidden;
    }

    #content-frame {
      width: 100%;
      height: calc(100% - 80px); /* CTA 높이만큼 제외 */
      border: none;
    }

    #cta-overlay {
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      height: 80px;
      background: <%= @link.cta_color || '#2563eb' %>;
      display: flex;
      align-items: center;
      justify-content: <%= @link.cta_position || 'center' %>;
      padding: 0 20px;
      box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
      z-index: 9999;
    }

    .cta-content {
      display: flex;
      align-items: center;
      gap: 20px;
    }

    .cta-text {
      color: white;
      font-size: 16px;
    }

    .cta-button {
      background: white;
      color: #1f2937;
      padding: 10px 24px;
      border-radius: 6px;
      text-decoration: none;
      font-weight: 600;
      transition: transform 0.2s;
    }

    .cta-button:hover {
      transform: scale(1.05);
    }
  </style>
</head>
<body>
  <iframe id="content-frame" src="<%= @link.original_url %>"></iframe>

  <div id="cta-overlay">
    <div class="cta-content">
      <span class="cta-text"><%= @link.cta_text %></span>
      <a href="<%= @link.cta_link %>" class="cta-button" target="_blank">
        <%= @link.cta_button_text || 'Learn More' %>
      </a>
    </div>
  </div>
</body>
</html>
```

## 주의사항 및 제한사항

### X-Frame-Options 문제
많은 웹사이트가 `X-Frame-Options: DENY` 또는 `SAMEORIGIN` 헤더를 설정하여 iframe 임베딩을 차단합니다.

**예시:**
- Google, Facebook, YouTube 등 대부분의 메이저 사이트들

**해결 방법:**
- 없음 (보안 정책이므로 우회 불가)
- 사용자에게 "이 사이트는 프레임에서 표시할 수 없습니다" 안내

### HTTPS 혼합 콘텐츠
- HTTPS 사이트에서 HTTP iframe 로드 시 브라우저가 차단
- 해결: 서비스를 HTTPS로만 운영

### CORS 정책
- iframe 내부 콘텐츠와 직접 통신 불가 (Same-Origin Policy)
- CTA는 독립적으로 작동하므로 문제없음

## 다음 단계
1. Rails 프로젝트 초기화
2. Link 모델 및 마이그레이션 생성
3. 컨트롤러 및 라우팅 설정
4. 기본 뷰 구현
5. Link 생성 폼 구현
6. 테스트 및 개선

## 향후 확장 가능 기능
- 클릭 추적 (Analytics)
- 다양한 CTA 템플릿
- 사용자 인증 및 대시보드
- QR 코드 생성
- A/B 테스트
