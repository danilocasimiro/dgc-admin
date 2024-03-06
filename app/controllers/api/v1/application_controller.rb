# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include Concerns::JwtToken
      include Concerns::HandleErrors

      around_action :wrap_in_transaction

      def wrap_in_transaction(&)
        ActiveRecord::Base.transaction(&)
      end
    end
  end
end
