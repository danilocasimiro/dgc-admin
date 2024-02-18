# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Validation do
  subject(:validation) { build(:validation) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it "validates the status enum values" do
      expect define_enum_for(:status).with_values(%i[pending canceled used])
    end

    it "validates the validation_type enum values" do
      expect define_enum_for(:validation_type).with_values(%i[registration password_recovery])
    end
  end
end
