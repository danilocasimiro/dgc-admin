# frozen_string_literal: true

class ProductType < ApplicationRecord
  belongs_to :company, inverse_of: :product_types

  has_many :products, inverse_of: :product_type

  before_destroy :validate_before_destroy

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :company_id

  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :with_company_id, ->(company_id) { where(company_id:) }

  def validate_before_destroy
    return if products.empty?

    errors.add(:base, 'Não é possível excluir este tipo de produto por conta que ele possui produtos associados.')
    throw(:abort)
  end

  class << self
    def relation_map
      %i[products]
    end
  end
end
