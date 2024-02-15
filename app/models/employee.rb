# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :tenant, inverse_of: :employees

  has_many :companies_employees, inverse_of: :employee, class_name: 'CompanyEmployee', dependent: :destroy
  has_many :companies, through: :companies_employees

  has_one :user, as: :profile, inverse_of: :profile, dependent: :destroy

  delegate :trial, :current_subscription, to: :tenant

  def allow_access?
    config = SystemConfiguration.first

    Date.today < (trial.end_at + config.grace_period_days) || current_subscription
  end

  class << self
    def relation_map
      %i[tenant companies user]
    end
  end
end
