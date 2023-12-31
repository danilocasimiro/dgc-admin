# frozen_string_literal: true

class Client < ApplicationRecord
  has_one :addressable

  has_many :company_clients, inverse_of: :client
  has_many :companies, through: :company_clients

  before_destroy :destroy_company_client_records

  def associate_with_company(company_id)
    CompanyClient.create!(client_id: id, company_id:)
  end

  def destroy_company_client_records
    company_clients.destroy_all
  end
end
