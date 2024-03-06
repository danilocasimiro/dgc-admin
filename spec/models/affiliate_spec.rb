require 'rails_helper'

RSpec.describe Affiliate do
  subject(:affiliate) { build(:affiliate) }

  describe 'associations' do
    it { is_expected.to have_many(:tenants) }
    it { is_expected.to have_one(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '.relation_map' do
    it 'returns an array of symbols' do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it 'returns expected relation symbols' do
      expected_relations = %i[user]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
