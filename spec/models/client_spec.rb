# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  subject(:client) { build(:client) }

  describe 'associations' do
    it { is_expected.to have_one(:address) }
    it { is_expected.to have_one(:user) }
    it { is_expected.to have_many(:company_clients) }
    it { is_expected.to have_many(:companies) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#associate_with_company' do
    let(:client) { create(:client) }
    let(:company) { create(:company) }

    it 'creates a new CompanyClient record' do
      expect do
        client.associate_with_company(company.id)
      end.to change(CompanyClient, :count).by(1)
    end

    it 'associates the client with the correct company' do
      client.associate_with_company(company.id)
      expect(client.company_clients.last.company_id).to eq(company.id)
    end

    it 'associates the client with the incorrect company' do
      expect { client.associate_with_company('123') }.to raise_error(
        ActiveRecord::RecordInvalid
      ) do |exception|
        expect(exception.message).to eq('Validation failed: Company must exist')
      end
    end

    it 'when associates already exists' do
      client.associate_with_company(company.id)
      expect { client.associate_with_company(company.id) }.to raise_error(
        ActiveRecord::RecordInvalid
      ) do |exception|
        expect(exception.message).to eq(
          'Validation failed: Este cliente já está associado a esta empresa'
        )
      end
    end
  end

  describe '.with_company_id' do
    let(:company_id) { 1 }
    let(:company) { create(:company, id: company_id) }

    it 'returns records associated with the specified company_id' do
      record = create(:client)
      create(:company_client, client: record, company:)

      expect(Client.with_company_id(company_id)).to include(record)
    end

    it 'does not return records associated with other company_id' do
      record = create(:client)
      create(:company_client, client: record, company: create(:company))

      expect(Client.with_company_id(company_id)).not_to include(record)
    end
  end

  describe '.relation_map' do
    it 'returns an array of symbols' do
      expect(described_class.relation_map).to be_an(Array)
      expect(described_class.relation_map).to all(be_a(Symbol))
    end

    it 'returns expected relation symbols' do
      expected_relations = %i[companies user]
      expect(described_class.relation_map).to match_array(expected_relations)
    end
  end
end
