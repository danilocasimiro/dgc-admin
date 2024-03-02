# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < BaseController
      include Concerns::UserContext

      before_action :set_resource, only: %i[show destroy update]

      def index
        raise ForbiddenError unless current_user.tenant? || current_user.employee?

        @models = current_user.profile.companies

        render json: paginate(@models)
      end

      def create
        raise ForbiddenError unless current_user.tenant?

        @model = model_class.create!(permitted_params.merge(tenant_id: current_user.profile_id))
        store_address

        render json: @model
      end

      def update
        @model.update!(permitted_params)
        update_address

        render json: @model
      end

      private

      def set_resource
        raise ForbiddenError unless current_user.tenant? || current_user.employee?

        @model = current_user.profile.companies.find(params[:id])
      end

      def permitted_params
        params.require(:company).permit(:name)
      end
    end
  end
end
