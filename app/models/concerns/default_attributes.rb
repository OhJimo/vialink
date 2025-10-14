module DefaultAttributes
  extend ActiveSupport::Concern

  DEFAULT_CTA_BUTTON_TEXT = "자세히 보기"
  DEFAULT_CTA_POSITION = "center"
  DEFAULT_CTA_COLOR = "#2563eb"

  included do
    before_validation :set_defaults, on: :create
  end

  private

  def set_defaults
    self.cta_button_text ||= DEFAULT_CTA_BUTTON_TEXT
    self.cta_position ||= DEFAULT_CTA_POSITION
    self.cta_color ||= DEFAULT_CTA_COLOR
  end
end
