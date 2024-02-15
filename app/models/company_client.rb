# frozen_string_literal: true

class CompanyClient < ApplicationRecord
  belongs_to :company, inverse_of: :company_clients
  belongs_to :client, inverse_of: :company_clients

  validate :unique_client_company_combination

  private

  def unique_client_company_combination
    if self.where(client_id:, company_id:).exists?
      errors.add(:base, "Este cliente já está associado a esta empresa")
    end
  end
end
