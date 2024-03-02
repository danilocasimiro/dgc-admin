module Api
  module V1
    class CompanyEmailTemplatesController < BaseController
      include Concerns::CompanyContext

      before_action :user_has_permission?
      before_action :set_resource, only: %i[show update]

      def index
        @models = model_class.with_company_id(current_company_id)

        render json: paginate(@models)
      end

      private

      def user_has_permission?
        raise ForbiddenError unless current_user.tenant? || current_user.employee?
      end

      def permitted_params
        params.require(:company_email_template).permit(:subject, :body)
      end

      def set_resource
        @model = model_class.with_company_id(current_company_id).find(params[:id])
      end
    end
  end
end
