# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  subject(:company) { build(:company) }

  describe 'associations' do
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to have_one(:address) }
    it { is_expected.to have_many(:companies_employees) }
    it { is_expected.to have_many(:employees) }
    it { is_expected.to have_many(:company_clients) }
    it { is_expected.to have_many(:clients) }
    it { is_expected.to have_many(:company_email_templates) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it do
      is_expected.to validate_uniqueness_of(:name).scoped_to(:tenant_id)
                                                  .case_insensitive
    end
  end

  describe '.with_user_id' do
    let(:user) { build(:user) }
    let(:tenant) { build(:tenant, user:) }

    it 'returns companies associated with the specified user_id' do
      associated_companies = create_list(:company, 3, tenant:)

      create_list(:company, 2)

      companies = described_class.with_user_id(user.id)

      expect(companies).to match_array(associated_companies)
    end

    it 'does not return companies associated with other user_ids' do
      create_list(:company, 3)

      companies = described_class.with_user_id(user.id)

      expect(companies).to be_empty
    end
  end

  describe '.relation_map' do
    it 'returns an array of symbols' do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it 'returns expected relation symbols' do
      expected_relations = %i[clients tenant address]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
