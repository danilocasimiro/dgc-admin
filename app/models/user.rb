# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord
  include BCrypt

  has_secure_password

  has_one :addressable

  has_many :companies, inverse_of: :user

  validates :email_address, presence: true, uniqueness: true

  before_destroy :validate_before_destroy

  def validate_before_destroy
    return if companies.empty?

    errors.add(:base, 'Não é possível excluir este usuario por conta que ele possui empresas associadas.')
    throw(:abort)
  end

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
