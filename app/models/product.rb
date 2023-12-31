# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :product_type, inverse_of: :products
end
