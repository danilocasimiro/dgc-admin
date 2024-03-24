# frozen_string_literal: true

module Api
  module V1
    class ProductTypesController < BaseController
      include Concerns::CompanyContext

      before_action :user_has_permission?

      def index
        @models = product_type_service.fetch_product_types(params)

        render json: @models
      end

      def show
        @model = product_type_service.fetch_product_type(params[:id], params)

        render json: @model
      end

      def update
        @model = product_type_service.update_product_type(params[:id], permitted_params)

        render json: @model
      end

      def create
        @model = product_type_service.create_product_type(permitted_params)

        render json: @model
      end

      def destroy
        product_type_service.destroy_product_type(params[:id])

        head :ok
      end

      private

      def user_has_permission?
        return false if current_user.tenant? || current_user.employee?

        raise ForbiddenError
      end

      def permitted_params
        params.require(:product_type).permit(:name)
              .merge(company_id: current_company_id)
      end

      def product_type_service
        ProductTypeService.new(current_company_id, request.headers['Authorization'])
      end
    end
  end
end
