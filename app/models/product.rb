# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :product_type, inverse_of: :products

  validates_presence_of :name, :price

  scope :with_company_id, ->(company_id) { joins(:product_type).where(product_type: { company_id: }) }

  class << self
    def relation_map
      %i[product_type]
    end
  end
end
