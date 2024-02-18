# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product do
  subject(:product) { build(:product) }

  describe 'associations' do
    it { is_expected.to belong_to(:product_type) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }

    it 'validates that price is greater than or equal to 0' do
      product.price = -10
      expect(product).not_to be_valid

      product.price = 0
      expect(product).to be_valid

      product.price = 10
      expect(product).to be_valid
    end
  end

  describe ".with_company_id" do
    let(:company) { product_type.company }
    let(:product_type) { build(:product_type) }

    it "returns products associated with the specified company_id" do
      associated_products = create_list(:product, 3, product_type: product_type)

      create_list(:product, 2)

      products = described_class.with_company_id(company.id)

      expect(products).to match_array(associated_products)
    end

    it "does not return products associated with other company_ids" do
      create_list(:product, 3)

      products = described_class.with_company_id(company.id)

      expect(products).to be_empty
    end
  end

  describe ".relation_map" do
    it "returns an array of symbols" do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it "returns expected relation symbols" do
      expected_relations = [:product_type]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
