# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  before_action :configure_mailer_settings

  private

  def configure_mailer_settings
    smtp_email_config = SmtpEmailConfiguration.find_by!(active: true)

    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      address: smtp_email_config.address,
      port: smtp_email_config.port,
      user_name: smtp_email_config.user_name,
      password: smtp_email_config.password,
      authentication: smtp_email_config.authentication,
      enable_starttls_auto: true
    }
  end
end
