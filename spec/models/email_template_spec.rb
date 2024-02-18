# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailTemplate do
  subject(:email_template) { build(:email_template) }

  describe 'associations' do
    it { is_expected.to have_many(:company_email_templates) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:body) }
  end
end
