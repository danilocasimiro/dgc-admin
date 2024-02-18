# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { create(:tenant_user) }

  describe 'associations' do
    it { is_expected.to belong_to(:profile).optional(true) }
    it { is_expected.to have_many(:validations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:friendly_id) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    it "validates the status enum values" do
      expect define_enum_for(:status).with_values(active: 0, inactive: 1)
    end
    it { is_expected.to allow_value("user@example.com").for(:email_address) }
    it { is_expected.to_not allow_value("invalid_email").for(:email_address) }
  end

  describe "delegations" do
    let(:tenant) { user.profile }

    it "delegates status and name to associated object" do
      expect(user).to respond_to(:name)
      expect(user).to respond_to(:last_subscription_status)
    end

    context "when last_subscription is present" do

      it "returns an instance of Subscription" do
        create(:subscription, tenant: tenant)

        expect(user.last_subscription).to be_an_instance_of(Subscription)
      end
    end

    context "when last_subscription is nil" do
      it "returns nil" do
        user = create(:user)

        expect(user.last_subscription).to be_nil
      end
    end
  end

  describe "#set_friendly_id" do
    it "returns the friendly_ids" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      expect(user1.friendly_id).to eq(1)
      expect(user2.friendly_id).to eq(2)
      expect(user3.friendly_id).to eq(3)
    end
  end

  describe ".relation_map" do
    it "returns an array of symbols" do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it "returns expected relation symbols" do
      expected_relations = %i[profile]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
