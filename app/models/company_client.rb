# frozen_string_literal: true

class CompanyClient < ApplicationRecord
  belongs_to :company, inverse_of: :company_clients
  belongs_to :client, inverse_of: :company_clients
end
