# frozen_string_literal: true

class Company < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_one :employee, as: :employable, inverse_of: :company

  belongs_to :tenant, inverse_of: :companies

  has_many :company_clients, inverse_of: :company
  has_many :clients, through: :company_clients
  has_many :product_types, inverse_of: :company

  before_destroy :validate_before_destroy, :destroy_product_types_records

  scope :with_user_id, ->(user_id) { joins(tenant: :user).where(user: { id: user_id }) }

  def validate_before_destroy
    return if clients.empty?

    errors.add(:base, 'Não é possível excluir esta empresa por conta que ele possui clientes associados.')
    throw(:abort)
  end

  def destroy_product_types_records
    return unless errors.empty?

    product_types.destroy_all
  end

  class << self
    def relation_map
      %i[clients tenant address]
    end
  end
end
