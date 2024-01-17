# frozen_string_literal: true

class Tenant < ApplicationRecord
  include FriendlyIdGenerator

  belongs_to :user, inverse_of: :tenant, dependent: :destroy

  has_many :companies, inverse_of: :tenant
  has_many :subscription_plans, inverse_of: :tenant

  before_destroy :validate_before_destroy

  scope :with_user_id, ->(user_id) { where(user_id:) }
  scope :friendly_id_conditions, -> {}

  def validate_before_destroy
    return if companies.empty?

    errors.add(:base, 'Não é possível excluir este inquilino por conta que ele possui empresas associadas.')
    throw(:abort)
  end

  class << self
    def relation_map
      %i[companies user]
    end
  end
end
