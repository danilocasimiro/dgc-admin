# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyEmailTemplate, type: :model do
  subject(:company_email_template) { build(:company_email_template) }

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:email_template) }
  end

  describe '#unique_email_template_company_combination' do
    let(:email_template) { create(:user_register_email_template_action) }
    let(:company) { create(:company) }

    context 'when the combination is unique' do
      before { create(:company_email_template, email_template:, company:) }

      it 'does not add an error to the base' do
        new_company_email_template =
          build(
            :company_email_template,
            email_template:,
            company: create(:company)
          )
        new_company_email_template.valid?
        expect(new_company_email_template.errors[:base]).not_to include(
          'Este template de email já está associado a esta empresa'
        )
      end
    end

    context 'when the combination is not unique' do
      before do
        create(:company_email_template, email_template:, company:)
      end

      it 'adds an error to the base' do
        new_company_email_template = build(:company_email_template,
                                           email_template:, company:)
        new_company_email_template.valid?
        expect(new_company_email_template.errors[:base]).to include(
          'Este template de email já está associado a esta empresa'
        )
      end
    end
  end
end
