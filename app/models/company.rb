# frozen_string_literal: true

class Company < ApplicationRecord
  has_one :addressable

  belongs_to :user, inverse_of: :companies

  has_many :company_clients, inverse_of: :company
  has_many :clients, through: :company_clients
  has_many :product_types, inverse_of: :company

  before_destroy :validate_before_destroy, :destroy_product_types_records

  def validate_before_destroy
    return if clients.empty?

    errors.add(:base, 'Não é possível excluir esta empresa por conta que ele possui clientes associados.')
    throw(:abort)
  end

  def destroy_product_types_records
    return unless errors.empty?

    product_types.destroy_all
  end
end
