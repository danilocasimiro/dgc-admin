# frozen_string_literal: true

module CompanyContext
  extend ActiveSupport::Concern

  included do
    before_action :user_authenticate?
    before_action :company_authenticate?
  end
end
