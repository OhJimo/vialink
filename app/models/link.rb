class Link < ApplicationRecord
  include CodeGenerator
  include DefaultAttributes

  belongs_to :user

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
    days = user.link_expiry_days
    self.expires_at = days ? days.days.from_now : nil
  end
end
