class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :links, dependent: :destroy

  enum :plan, { free: 0, pro: 1, lifetime: 2 }

  # 플랜별 월 생성 제한
  def monthly_link_limit
    case plan
    when "free" then 10
    when "pro" then 300
    when "lifetime" then 500
    end
  end

  # 플랜별 링크 만료일 (일 단위)
  def link_expiry_days
    case plan
    when "free" then 5
    when "pro" then 30
    when "lifetime" then nil  # 영구
    end
  end

  # 이번 달 생성한 링크 수
  def current_month_links_count
    links.where("created_at >= ?", Time.current.beginning_of_month).count
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
