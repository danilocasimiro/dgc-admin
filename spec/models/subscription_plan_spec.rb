# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPlan do
  subject(:subscription_plan) { build(:subscription_plan) }

  describe 'associations' do
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:activation_months) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

    it 'validates that activation_months is greater than or equal to 0' do
      subscription_plan.activation_months = -10
      expect(subscription_plan).not_to be_valid

      subscription_plan.activation_months = 0
      expect(subscription_plan).to be_valid

      subscription_plan.activation_months = 10
      expect(subscription_plan).to be_valid
    end

    it 'validates that price is greater than or equal to 0' do
      subscription_plan.price = -10
      expect(subscription_plan).not_to be_valid

      subscription_plan.price = 0
      expect(subscription_plan).to be_valid

      subscription_plan.price = 10
      expect(subscription_plan).to be_valid
    end
  end

  describe '.relation_map' do
    it 'returns an array of symbols' do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it 'returns expected relation symbols' do
      expected_relations = %i[subscriptions]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
