# frozen_string_literal: true

class ProductType < ApplicationRecord
  belongs_to :company, inverse_of: :product_types

  has_many :products, inverse_of: :product_type, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name,
                          scope: :company_id,
                          uniqueness: { case_sensitive: false }

  scope :with_company_id, ->(company_id) { where(company_id:) }

  class << self
    def relation_map
      %i[products]
    end
  end
end
