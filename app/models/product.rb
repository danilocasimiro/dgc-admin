# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :product_type, inverse_of: :products

  scope :with_company_id, ->(company_id) { joins(:product_type).where(product_type: { company_id: }) }
end
