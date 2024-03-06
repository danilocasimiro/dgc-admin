# frozen_string_literal: true

module Api
  module V1
    class ClientsController < BaseController
      include Concerns::CompanyContext

      before_action :set_resource, only: %i[show update destroy]
      before_action :user_has_permission?

      def index
        @models = model_class.with_company_id(current_company_id)

        render json: paginate(@models)
      end

      def create
        @model = model_class.create!(permitted_params)
        create_user
        store_address
        associate_with_company
        send_email

        render json: @model
      end

      def update
        @model.update!(permitted_params)
        update_user
        update_address

        render json: @model
      end

      private

      def user_has_permission?
        return false if current_user.tenant? || current_user.employee?

        raise ForbiddenError
      end

      def user_params
        params.require(:user).permit(%i[email_address password])
      end

      def permitted_params
        params.require(:client).permit(:name)
      end

      def set_resource
        @model =
          model_class.with_company_id(current_company_id).find(params[:id])
      end

      def associate_with_company
        @model.associate_with_company(current_company_id)
      end

      def send_email
        return unless @model.persisted?

        origin = request.headers['Origin'] || request.headers['Referer']

        UserRegistrationMailer.send_email(@model.user, origin).deliver_now
      end
    end
  end
end
