# frozen_string_literal: true

class CompanyEmployee < ApplicationRecord
  belongs_to :company, inverse_of: :companies_employees
  belongs_to :employee, inverse_of: :companies_employees

  validate :unique_employee_company_combination

  private

  def unique_employee_company_combination
    if self.where(employee_id:, company_id:).exists?
      errors.add(:base, "Este colaborador já está associado a esta empresa")
    end
  end
end
