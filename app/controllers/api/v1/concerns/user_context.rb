# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module UserContext
        extend ActiveSupport::Concern

        included do
          before_action :user_authenticate?
          before_action :allow_access?
        end

        private

        def allow_access?
          return if user_has_active_subscription

          render json: { error: 'Sua assinatura está expirada. Por favor, realize uma nova assinatura.' },
                status: :unauthorized
        end

        def user_has_active_subscription
          !current_user.needs_subscription_to_access || current_user.profile.allow_access?
        end
      end
    end
  end
end
