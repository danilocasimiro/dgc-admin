# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trial do
  subject(:trial) { build(:trial) }

  describe 'associations' do
    it { is_expected.to belong_to(:tenant) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_at) }
    it { is_expected.to validate_presence_of(:end_at) }

    it "validates that end_at is greater than start_at" do
      expect validate_numericality_of(:end_at).is_greater_than(:start_at)
    end
  end
end
