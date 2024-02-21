require 'rails_helper'

RSpec.describe Menu, type: :model do
  subject(:menu) { build(:menu) }

  describe 'associations' do
    it { is_expected.to belong_to(:parent).optional }
    it { should have_many(:children).class_name('Menu').with_foreign_key('parent_id') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:users_allowed) }
  end
end
