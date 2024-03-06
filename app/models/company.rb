# frozen_string_literal: true

class Company < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy

  belongs_to :tenant, inverse_of: :companies

  has_many :companies_employees,
           inverse_of: :company, class_name: 'CompanyEmployee'
  has_many :employees, through: :companies_employees, dependent: :destroy
  has_many :company_clients, inverse_of: :company, dependent: :destroy
  has_many :clients, through: :company_clients, dependent: :destroy
  has_many :product_types, inverse_of: :company, dependent: :destroy
  has_many :company_email_templates, inverse_of: :company, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name,
                          scope: :tenant_id,
                          uniqueness: { case_sensitive: false }

  scope :with_user_id, lambda { |user_id|
    joins(tenant: :user).where(user: { id: user_id })
  }

  class << self
    def relation_map
      %i[clients tenant address]
    end
  end
end
