# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address do
  subject(:address) { build(:client_address) }

  describe 'associations' do
    it { is_expected.to belong_to(:addressable) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:street) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:neighborhood) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip_code) }
  end

  it "validates the format of zip_code" do
    subject.zip_code = "12345-678"

    expect(address).to be_valid
  end

  it "invalidates incorrect format of zip_code" do
    subject.zip_code ="12345"

    expect(address).not_to be_valid
    expect(address.errors[:zip_code]).to include("formato de CEP inválido. Use o formato: XXXXX-XXX")
  end
end
