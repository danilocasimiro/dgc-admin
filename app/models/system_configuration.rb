# frozen_string_literal: true

class SystemConfiguration < ApplicationRecord
  has_one :smtp_email_configuration, inverse_of: :system_configurations

  validates_presence_of :maintenance_mode, :grace_period_days
  validates :grace_period_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
