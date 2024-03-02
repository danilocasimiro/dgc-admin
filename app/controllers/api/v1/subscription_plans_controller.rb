# frozen_string_literal: true

module Api
  module V1
    class SubscriptionPlansController < BaseController
      include Concerns::UserContext

      before_action :user_has_permission?, except: :index
      before_action :set_resource, only: %i[show update]

      def index
        @models = model_class.all

        render json: paginate(@models)
      end

      private

      def user_has_permission?
        raise ForbiddenError unless current_user.admin?
      end

      def permitted_params
        params.require(:subscription_plan).permit(:name, :description, :activation_months, :price)
      end
    end
  end
end
