# frozen_string_literal: true

module Api
  module V1
    class EmailTemplatesController < BaseController
      include Concerns::UserContext

      before_action :admin?
      before_action :set_resource, only: %i[show update]

      def index
        @models = model_class.all

        render json: paginate(@models)
      end

      private

      def admin?
        return false if current_user.admin?

        raise ForbiddenError
      end

      def permitted_params
        params.require(:email_template).permit(:subject, :body)
      end
    end
  end
end
