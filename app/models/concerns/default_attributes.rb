module DefaultAttributes
  extend ActiveSupport::Concern

  included do
    before_validation :set_defaults, on: :create
  end

  private

  def set_defaults
    self.cta_button_text ||= "자세히 보기"
    self.cta_position ||= "center"
    self.cta_color ||= "#2563eb"
  end
end
