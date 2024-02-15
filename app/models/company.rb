# frozen_string_literal: true

class Company < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy

  belongs_to :tenant, inverse_of: :companies

  has_many :companies_employees, inverse_of: :company, class_name: 'CompanyEmployee'
  has_many :employees, through: :companies_employees
  has_many :company_clients, inverse_of: :company
  has_many :clients, through: :company_clients
  has_many :product_types, inverse_of: :company
  has_many :company_email_templates, inverse_of: :company

  before_destroy :validate_before_destroy, :destroy_product_types_records

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :tenant_id

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
