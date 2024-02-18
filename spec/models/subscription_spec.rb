# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  subject(:subscription) { build(:subscription) }

  describe 'associations' do
    it { is_expected.to belong_to(:subscription_plan) }
    it { is_expected.to belong_to(:tenant) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_at) }

    it "validates the status enum values" do
      expect define_enum_for(:status).with_values(%i[active inactive suspended pending])
    end

    it 'validates that end_at is greater than start_at' do
      subscription.start_at = Date.today
      subscription.end_at = Date.today - 1.days
      expect(subscription).not_to be_valid

      subscription.start_at = Date.today
      subscription.end_at = Date.today + 1.days
      expect(subscription).to be_valid

      subscription.start_at = Date.today
      subscription.end_at = nil
      expect(subscription).to be_valid
    end
  end

  describe ".with_tenant_id" do
    let(:tenant_id) { 1 }
    let(:tenant) { create(:tenant, id: tenant_id) }  

    it "returns records associated with the specified tenant_id" do
      record = create(:subscription, tenant: tenant)

      expect(described_class.with_tenant_id(tenant_id)).to include(record)
    end

    it "does not return records associated with other tenant_id" do
      record = create(:subscription)

      expect(described_class.with_tenant_id(tenant_id)).not_to include(record)
    end
  end

  describe "before_save callbacks" do
    let(:subscription) { create(:subscription, subscription_plan: subscription_plan) }
    let(:subscription_plan) { create(:subscription_plan) }

    before do
      subscription.save
    end

    it "sets start_at to today's date before saving" do
      expect(subscription.start_at).to eq Date.today
    end

    it "sets end_at based on activation months before saving" do
      expected_end_date = Date.today.advance(months: subscription_plan.activation_months)

      expect(subscription.end_at).to eq expected_end_date
    end
  end

  describe ".relation_map" do
    it "returns an array of symbols" do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it "returns expected relation symbols" do
      expected_relations = %i[subscription_plan tenant]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
