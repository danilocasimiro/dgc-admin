# frozen_string_literal: true

class Tenant < ApplicationRecord
  belongs_to :user, inverse_of: :tenant

  has_many :companies, inverse_of: :tenant

  has_one :addressable

  before_destroy :validate_before_destroy

  scope :with_user_id, ->(user_id) { where(user_id:) }

  def validate_before_destroy
    return if companies.empty?

    errors.add(:base, 'Não é possível excluir este inquilino por conta que ele possui empresas associadas.')
    throw(:abort)
  end
end
