class Link < ApplicationRecord
  include CodeGenerator
  include DefaultAttributes

  belongs_to :user, optional: true  # 게스트 사용자도 가능하도록

  validates :original_url, :code, presence: true
  validates :code, uniqueness: true
  validates :original_url, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid URL"
  }

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
    # 게스트 사용자는 1일, 로그인 사용자는 플랜에 따라
    if user.present?
      days = user.link_expiry_days
      self.expires_at = days ? days.days.from_now : nil
    else
      # 게스트는 1일만 보관
      self.expires_at = 1.day.from_now
    end
  end
end
