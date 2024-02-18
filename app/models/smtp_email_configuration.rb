class SmtpEmailConfiguration < ApplicationRecord
  has_many :system_configurations, inverse_of: :smtp_email_configuration

  validates_presence_of :active, :address, :name, :user_name,
    :password, :port, :domain, :authentication
end
