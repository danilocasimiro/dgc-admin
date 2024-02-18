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
end
