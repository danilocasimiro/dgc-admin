# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenant do
  subject(:tenant) { build(:tenant) }

  describe 'associations' do
    it { is_expected.to have_one(:trial) }
    it { is_expected.to have_one(:user) }
    it { is_expected.to belong_to(:affiliate).optional }
    it { is_expected.to have_many(:employees) }
    it { is_expected.to have_many(:companies) }
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '.accessible_by_user' do
    let(:affiliate) { create(:affiliate) }

    before do
      create_list(:tenant, 3)
      create_list(:tenant, 2, affiliate:)
    end

    context 'when user type is Admin' do
      let(:admin_user) { create(:user) }

      it 'returns all tenants' do
        expect(described_class.accessible_by_user(admin_user).count).to eq(5)
      end
    end

    context 'when user type is Affiliate' do
      let(:affiliate_user) { affiliate.user }
      let(:result) { described_class.accessible_by_user(affiliate_user).count }

      it 'returns associated tenants' do
        expect(result).to eq(2)
      end
    end

    context 'when user type does not have access' do
      let(:employee_user) { create(:employee_user) }
      let(:result) { described_class.accessible_by_user(employee_user) }

      it 'raises ForbiddenError' do
        expect { result }.to raise_error(ForbiddenError)
      end
    end
  end

  describe '#allow_access?' do
    before do
      allow(tenant).to receive(:current_subscription).and_return(nil)
      allow(tenant).to receive(:trial).and_return(trial)

      create(:system_configuration, grace_period_days: 0)
    end

    context 'when within trial period and grace period' do
      let(:trial) { create(:trial, end_at: Date.today + 5.days) }

      it 'allows access' do
        expect(tenant.allow_access?).to eq(true)
      end
    end

    context 'when outside trial period and grace period' do
      let(:trial) { create(:trial, end_at: Date.today - 5.days) }

      it 'does not allow access' do
        expect(tenant.allow_access?).to eq(nil)
      end
    end

    context 'when current subscription exists' do
      let(:trial) { create(:trial, end_at: Date.today - 1.days) }

      before do
        allow(tenant).to receive(:current_subscription).and_return(true)
      end

      it 'allows access' do
        expect(tenant.allow_access?).to eq(true)
      end
    end

    context 'when current subscription not exists' do
      let(:trial) { create(:trial, end_at: Date.today - 1.days) }

      it 'allows access' do
        expect(tenant.allow_access?).to eq(nil)
      end
    end
  end

  describe '#last_subscription' do
    it 'returns the last subscription' do
      create(:subscription, tenant:,
                            created_at: 2.days.ago)
      create(:subscription, tenant:,
                            created_at: 1.day.ago)
      last_subscription = create(:subscription, tenant:,
                                                created_at: Time.current)

      expect(tenant.last_subscription).to eq(last_subscription)
    end
  end

  describe '#current_subscription' do
    before { create(:system_configuration) }

    it 'returns the current subscription' do
      create(:subscription, tenant:, status: :inactive,
                            created_at: 2.days.ago)
      active_subscription = create(:subscription, tenant:, status: :active,
                                                  created_at: 1.day.ago)
      create(:subscription, tenant:, status: :inactive,
                            created_at: Time.current)

      expect(tenant.current_subscription).to eq(active_subscription)
    end
  end

  describe '.relation_map' do
    it 'returns an array of symbols' do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it 'returns expected relation symbols' do
      expected_relations = %i[companies user]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
