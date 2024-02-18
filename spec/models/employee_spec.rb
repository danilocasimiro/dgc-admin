# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Employee do
  subject(:employee) { create(:employee) }

  describe 'associations' do
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to have_many(:companies_employees) }
    it { is_expected.to have_many(:companies) }
    it { is_expected.to have_one(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:tenant_id).case_insensitive }
  end

  describe "delegations" do
    it "delegates trial and current_subscription to associated object" do
      expect(employee.trial).to be_an_instance_of(Trial)
      expect(employee).to respond_to(:current_subscription)
    end
  end

  describe "#allow_access?" do
    let(:tenant) { employee.tenant }

    before do
      allow(employee.tenant).to receive(:current_subscription).and_return(nil)
      allow(tenant).to receive(:trial).and_return(trial)

      create(:system_configuration, grace_period_days: 0)
    end

    context "when within trial period and grace period" do
      let(:trial) { create(:trial, end_at: Date.today + 5.days) }

      it "allows access" do
        expect(employee.allow_access?).to eq(true)
      end
    end

    context "when outside trial period and grace period" do
      let(:trial) { create(:trial, end_at: Date.today - 5.days) }

      it "does not allow access" do
        expect(employee.allow_access?).to eq(nil)
      end
    end

    context "when current subscription exists" do
      let(:trial) { create(:trial, end_at: Date.today - 1.days) }

      before do
        allow(employee.tenant).to receive(:current_subscription).and_return(true)
      end

      it "allows access" do
        expect(employee.allow_access?).to eq(true)
      end
    end

    context "when current subscription not exists" do
      let(:trial) { create(:trial, end_at: Date.today - 1.days) }

      it "allows access" do
        expect(employee.allow_access?).to eq(nil)
      end
    end
  end

  describe ".relation_map" do
    it "returns an array of symbols" do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it "returns expected relation symbols" do
      expected_relations = %i[tenant companies user]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
