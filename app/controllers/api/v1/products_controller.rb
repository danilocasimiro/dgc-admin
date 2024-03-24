# frozen_string_literal: true

module Api
  module V1
    class ProductsController < BaseController
      include Concerns::CompanyContext

      before_action :user_has_permission?

      def index
        api_response = product_service.fetch_products(params)
        response.headers['Total-Pages'] = api_response.headers['total-pages']
        @models = api_response.body

        render json: @models
      end

      def show
        @model = product_service.fetch_product(params[:id], params)

        render json: @model
      end

      def update
        @model = product_service.update_product(params[:id], permitted_params)

        render json: @model
      end

      def create
        @model = product_service.create_product(permitted_params)

        render json: @model
      end

      def destroy
        product_service.destroy_product(params[:id])

        head :ok
      end

      private

      def user_has_permission?
        return false if current_user.tenant? || current_user.employee?

        raise ForbiddenError
      end

      def permitted_params
        params.require(:product).permit(:name, :product_type_id, :price, :stock)
      end

      def product_service
        ProductService.new(current_company_id, request.headers['Authorization'])
      end
    end
  end
end
