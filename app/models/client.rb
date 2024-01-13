# frozen_string_literal: true

class Client < ApplicationRecord
  include FriendlyIdGenerator

  has_one :address, as: :addressable, dependent: :destroy

  belongs_to :user, inverse_of: :client, dependent: :destroy

  has_many :company_clients, inverse_of: :client, dependent: :destroy
  has_many :companies, through: :company_clients

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
