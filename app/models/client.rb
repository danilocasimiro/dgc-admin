# frozen_string_literal: true

class Client < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_one :user, as: :profile, inverse_of: :profile, dependent: :destroy

  has_many :company_clients, inverse_of: :client, dependent: :destroy
  has_many :companies, through: :company_clients

  validates_presence_of :name

  scope :with_company_id, ->(company_id) { joins(:company_clients).where(company_clients: { company_id: }) }

  def associate_with_company(company_id)
    CompanyClient.create!(client_id: id, company_id:)
  end

  class << self
    def relation_map
      %i[companies user]
    end
  end
end
