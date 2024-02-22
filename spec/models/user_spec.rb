# frozen_string_literal: true
require 'bcrypt'
require 'rails_helper'

RSpec.describe User do
  subject(:user) { create(:tenant_user) }

  describe 'associations' do
    it { is_expected.to belong_to(:profile).optional(true) }
    it { is_expected.to have_many(:validations) }
  end

  describe 'validations' do
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

  describe '#admin?' do
    context 'when user is admin' do
      let(:user) { build(:user) }
    
      it 'returns truthy' do
        expect(user.admin?).to be_truthy
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:employee_user) }

      it 'returns falsey' do
        expect(user.admin?).to be_falsey
      end
    end
  end

  describe '#name' do
    context 'when user has no name' do
      let(:user) { build(:user) }
    
      it 'returns email_address' do
        expect(user.name).to eq(user.email_address)
      end
    end

    context 'when user has name' do
      let(:user) { build(:employee_user) }

      it 'returns profile name' do
        expect(user.name).to eq(user.profile.name)
      end
    end
  end

  describe '#type' do
    context 'when user is a admin' do
      let(:user) { build(:user) }
    
      it 'returns email_address' do
        expect(user.type).to eq('Admin')
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:employee_user) }

      it 'returns profile name' do
        expect(user.type).to eq(user.profile.class)
      end
    end
  end

  describe '#tenant?' do
    context 'when user is a tenant' do
      let(:user) { build(:tenant_user) }
    
      it 'returns email_address' do
        expect(user.tenant?).to be_truthy
      end
    end

    context 'when user is not a tenant' do
      let(:user) { build(:user) }

      it 'returns profile name' do
        expect(user.tenant?).to be_falsey
      end
    end
  end

  describe '#client?' do
    context 'when user is a client' do
      let(:user) { build(:client_user) }
    
      it 'returns email_address' do
        expect(user.client?).to be_truthy
      end
    end

    context 'when user is not a client' do
      let(:user) { build(:user) }

      it 'returns profile name' do
        expect(user.client?).to be_falsey
      end
    end
  end

  describe '#employee?' do
    context 'when user is a employee' do
      let(:user) { build(:employee_user) }
    
      it 'returns email_address' do
        expect(user.employee?).to be_truthy
      end
    end

    context 'when user is not a employee' do
      let(:user) { build(:user) }

      it 'returns profile name' do
        expect(user.employee?).to be_falsey
      end
    end
  end

  describe '#affiliate?' do
    context 'when user is a affiliate' do
      let(:user) { build(:affiliate_user) }
    
      it 'returns email_address' do
        expect(user.affiliate?).to be_truthy
      end
    end

    context 'when user is not a affiliate' do
      let(:user) { build(:user) }

      it 'returns profile name' do
        expect(user.affiliate?).to be_falsey
      end
    end
  end

  describe '#menu' do
    before do
      create_list(:menu, 4, company: true, users_allowed: 'admin')
      create_list(:menu, 3, company: false, users_allowed: 'admin')
      create_list(:menu, 2, company: true, users_allowed: 'tenant')
      create_list(:menu, 7, company: false, users_allowed: 'tenant')
    end

    context 'when company is send' do
      context 'when user is admin' do
        let(:user) { create(:user) }

        it 'return only 4 menus' do
          expect(user.menu(true).count).to eq(4)
        end
      end

      context 'when user is not admin' do
        let(:user) { create(:tenant_user) }

        it 'return only 2 menus' do
          expect(user.menu(true).count).to eq(2)
        end
      end
    end

    context 'when company is not send' do
      let(:company) { nil }

      context 'when user is admin' do
        let(:user) { create(:user) }

        it 'return only 3 menus' do
          expect(user.menu.count).to eq(3)
        end
      end

      context 'when user is not admin' do
        let(:user) { create(:tenant_user) }

        it 'return only 7 menus' do
          expect(user.menu.count).to eq(7)
        end
      end
    end
  end

  describe '.authenticate' do
    let(:password) { 'password' }
    let(:email) { 'test@example.com'}
    let(:user) { create(:user, email_address: email, password: password) }

    context 'when email and password are correct' do
      before do
        allow(user).to receive(:authenticate).and_return(true)
      end

      it 'returns the user' do
        authenticated_user = described_class.authenticate(user.email_address, password)
        expect(authenticated_user).to eq(user)
      end
    end

    context 'when email is correct but password is incorrect' do
      it 'returns nil' do
        authenticated_user = described_class.authenticate(user.email_address, 'wrong_password')
        expect(authenticated_user).to be_nil
      end
    end

    context 'when email is incorrect' do
      it 'returns nil' do
        authenticated_user = described_class.authenticate('wrong@example.com', password)
        expect(authenticated_user).to be_nil
      end
    end
  end

  describe '#expiration_date' do
    context 'when user is a tenant' do
      before { create(:system_configuration, grace_period_days: 0) }

      let(:user) { create(:tenant_user) }

      context 'when tenant has a subscription' do
        let(:subscription) do
          create(:subscription, tenant: user.profile)
        end

        it 'returns subscription end_at' do
          expect(subscription.tenant.user.expiration_date).to eq(subscription.end_at)
        end
      end

      context 'when tenant has not a subscription' do
        it 'returns trial end_at' do
          expect(user.expiration_date).to eq(user.profile.trial.end_at)
        end
      end
    end

    context 'when user is not a tenant' do
      let(:user) { build(:user) }

      it 'returns profile name' do
        expect(user.expiration_date).to be_nil
      end
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
