# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord
  include BCrypt

  has_secure_password

  has_one :client, inverse_of: :user
  has_one :tenant, inverse_of: :user

  has_many :companies, through: :tenant

  validates :email_address, presence: true, uniqueness: true

  def password
    @password ||= Password.new(password_digest)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_digest = @password
  end

  class << self
    def authenticate(email_address, password)
      user = find_by(email_address:)

      user if user&.authenticate(password)
    end
  end
end
