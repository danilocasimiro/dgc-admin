# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductType do
  subject(:product_type) { build(:product_type) }

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:products) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }
  end

  describe ".with_company_id" do
    let(:company_id) { 1 }
    let(:company) { create(:company, id: company_id) }  

    it "returns records associated with the specified company_id" do
      record = create(:product_type, company: company)

      expect(described_class.with_company_id(company_id)).to include(record)
    end

    it "does not return records associated with other company_id" do
      record = create(:product_type)

      expect(described_class.with_company_id(company_id)).not_to include(record)
    end
  end

  describe ".relation_map" do
    it "returns an array of symbols" do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it "returns expected relation symbols" do
      expected_relations = %i[products]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
