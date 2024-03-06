# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module CompanyContext
        extend ActiveSupport::Concern

        included do
          before_action :user_authenticate?
          before_action :company_authenticate?
        end
      end
    end
  end
end
