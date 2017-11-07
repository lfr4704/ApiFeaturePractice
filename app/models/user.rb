class User < ApplicationRecord
  has_one :api_key
  before_create :build_api_key

  private

  def build_api_key
    ApiKey.new(user: self)
  end
end
