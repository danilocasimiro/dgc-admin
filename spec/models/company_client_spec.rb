# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyClient, type: :model do
  subject(:company_client) { build(:company_client) }

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:client) }
  end

  describe '#unique_client_company_combination' do
    let(:client) { create(:client) }
    let(:company) { create(:company) }

    context 'when the combination is unique' do
      before { create(:company_client, client:, company:) }

      it 'does not add an error to the base' do
        new_company_client =
          build(:company_client, client:, company: create(:company))
        new_company_client.valid?
        expect(new_company_client.errors[:base]).not_to include(
          'Este cliente já está associado a esta empresa'
        )
      end
    end

    context 'when the combination is not unique' do
      before { create(:company_client, client:, company:) }

      it 'adds an error to the base' do
        new_company_client = build(:company_client, client:, company:)
        new_company_client.valid?
        expect(new_company_client.errors[:base]).to include(
          'Este cliente já está associado a esta empresa'
        )
      end
    end
  end
end
