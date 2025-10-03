class Link < ApplicationRecord
  include CodeGenerator
  include DefaultAttributes

  validates :original_url, :code, presence: true
  validates :code, uniqueness: true
  validates :original_url, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid URL"
  }
end
