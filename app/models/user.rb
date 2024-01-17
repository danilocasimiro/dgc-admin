# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord
  include BCrypt

  attr_accessor :company_id

  has_secure_password

  has_one :client, inverse_of: :user, dependent: :destroy
  has_one :tenant, inverse_of: :user, dependent: :destroy

  has_many :companies, through: :tenant

  validates :email_address, presence: true, uniqueness: true

  def admin?
    id == 1
  end

  def password
    @password ||= Password.new(password_digest)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_digest = @password
  end

  def name
    tenant ? tenant.name : client.name
  end

  def type
    tenant ? tenant.class : client.class
  end

  def friendly_id
    tenant ? tenant.friendly_id : client.friendly_id
  end

  def allow_access?
    return true unless tenant

    Date.today < tenant.trial.end_at || tenant&.current_subscription
  end

  class << self
    def authenticate(email_address, password)
      user = find_by(email_address:)

      user if user&.authenticate(password)
    end
  end
end
