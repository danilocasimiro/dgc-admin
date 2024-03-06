# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SystemConfiguration do
  subject(:system_configuration) { build(:system_configuration) }

  describe 'associations' do
    it 'has one smtp_email_configuration' do
      is_expected.to respond_to(:smtp_email_configuration)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:grace_period_days) }

    it 'validates that grace period days is greater than or equal to 0' do
      system_configuration.grace_period_days = -10
      expect(system_configuration).not_to be_valid

      system_configuration.grace_period_days = 0
      expect(system_configuration).to be_valid

      system_configuration.grace_period_days = 10
      expect(system_configuration).to be_valid
    end
  end
end
