# frozen_string_literal: true

require 'bcrypt'

class User < ApplicationRecord
  include BCrypt

  attr_accessor :company_id

  has_secure_password

  belongs_to :profile, polymorphic: true, optional: true

  has_many :validations, inverse_of: :user, dependent: :destroy

  delegate :status, to: :last_subscription, prefix: true, allow_nil: true
  delegate :last_subscription, to: :profile, allow_nil: true
  delegate :name, to: :profile, prefix: false, allow_nil: true

  enum status: { active: 0, inactive: 1 }

  validates_presence_of :email_address, :password_digest, :status

  validates :email_address, presence: true, uniqueness: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :set_friendly_id, :uniqueness_profile_type_and_profile_id

  def admin?
    profile.nil?
  end

  def uniqueness_profile_type_and_profile_id
    return unless User.where(profile_type:, profile_id:).exists?

    errors.add(:profile_type, 'Já existe a associação.')
  end

  def password
    @password =
      password_digest ? Password.new(password_digest) : nil
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_digest = @password
  end

  def name
    profile&.name || email_address
  end

  def type
    profile&.class || 'Admin'
  end

  def tenant?
    profile&.is_a?(Tenant)
  end

  def client?
    profile&.is_a?(Client)
  end

  def employee?
    profile&.is_a?(Employee)
  end

  def affiliate?
    profile&.is_a?(Affiliate)
  end

  def needs_subscription_to_access
    tenant? || employee?
  end

  def menu(company)
    menu_type = profile_type.nil? ? 'admin' : profile_type.downcase

    Menu.where(
      'users_allowed LIKE ? and company  = ?', "%#{menu_type}%", !!company
    )
  end

  def expiration_date
    return nil unless tenant?

    profile&.current_subscription&.end_at || profile&.trial&.end_at
  end

  private

  def set_friendly_id
    last_friendly_id = User.last&.friendly_id || 0
    self.friendly_id = last_friendly_id + 1
  end

  class << self
    def authenticate(email_address, password)
      user = find_by(email_address:)

      user if user&.authenticate(password)
    end

    def relation_map
      %i[profile]
    end
  end
end
