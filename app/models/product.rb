# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :product_type, inverse_of: :products

  validates_presence_of :name, :price
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :with_company_id, lambda { |company_id|
    joins(:product_type).where(product_types: { company_id: })
  }

  class << self
    def relation_map
      %i[product_type]
    end
  end
end
