# frozen_string_literal: true

class ProductType < ApplicationRecord
  belongs_to :company, inverse_of: :product_types

  has_many :products, inverse_of: :product_type

  before_destroy :validate_before_destroy

  def validate_before_destroy
    return if products.empty?

    errors.add(:base, 'Não é possível excluir este tipo de produto por conta que ele possui produtos associados.')
    throw(:abort)
  end
end
