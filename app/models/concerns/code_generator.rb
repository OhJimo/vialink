module CodeGenerator
  extend ActiveSupport::Concern

  included do
    before_validation :generate_code, on: :create
  end

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(6)
  end
end
