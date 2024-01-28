# frozen_string_literal: true

class CompanyEmployee < ApplicationRecord
  belongs_to :company, inverse_of: :companies_employees
  belongs_to :employee, inverse_of: :companies_employees
end
