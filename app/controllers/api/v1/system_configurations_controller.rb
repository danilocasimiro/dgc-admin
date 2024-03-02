# frozen_string_literal: true

module Api
  module V1
    class SystemConfigurationsController < BaseController
      include Concerns::UserContext

      before_action :user_authenticate?, :allow_access?, except: %i[maintenance_mode]
      before_action :set_resource, only: %i[update show]

      def maintenance_mode
        render json: SystemConfiguration.first.maintenance_mode
      end

      private

      def permitted_params
        params.require(:system_configuration).permit(%i[maintenance_mode grace_period_days])
      end

      def set_resource
        raise ForbiddenError unless current_user.admin?

        @model = model_class.find(params[:id])
      end
    end
  end
end
