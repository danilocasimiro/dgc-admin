# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyEmployee do
  subject(:company_employee) { build(:company_employee) }

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:employee) }
  end

  describe '#unique_employee_company_combination' do
    let(:employee) { create(:employee) }
    let(:company) { create(:company) }

    context 'when the combination is unique' do
      before { create(:company_employee, employee:, company:) }

      it 'does not add an error to the base' do
        new_company_employee =
          build(:company_employee, employee:, company: create(:company))
        new_company_employee.valid?
        expect(new_company_employee.errors[:base]).not_to include(
          'Este colaborador já está associado a esta empresa'
        )
      end
    end

    context 'when the combination is not unique' do
      before { create(:company_employee, employee:, company:) }

      it 'adds an error to the base' do
        new_company_employee = build(:company_employee, employee:, company:)
        new_company_employee.valid?
        expect(new_company_employee.errors[:base]).to include(
          'Este colaborador já está associado a esta empresa'
        )
      end
    end
  end
end
