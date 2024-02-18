# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmtpEmailConfiguration do
  subject(:smtp_email_configuration) { build(:smtp_email_configuration) }

  describe 'associations' do
    it { is_expected.to have_many(:system_configurations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:active) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:user_name) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:port) }
    it { is_expected.to validate_presence_of(:domain) }
    it { is_expected.to validate_presence_of(:authentication) }
  end
end
