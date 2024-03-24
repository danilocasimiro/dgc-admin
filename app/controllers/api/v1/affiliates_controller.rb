# frozen_string_literal: true

module Api
  module V1
    class AffiliatesController < BaseController
      include Concerns::UserContext

      before_action :admin?, only: %i[create index]
      before_action :set_resource, only: %i[destroy show update]

      def index
        @models = model_class.all

        render json: paginate(@models)
      end

      def create
        @model = model_class.create!(permitted_params)
        create_user
        send_email
        render json: @model
      end

      def update
        return raise ForbiddenError unless user_has_permission?

        @model.update!(permitted_params)
        update_user

        render json: @model
      end

      private

      def user_params
        params.require(:user).permit(%i[email_address password])
      end

      def permitted_params
        params.require(:affiliate).permit(:name)
      end

      def admin?
        return false if current_user.admin?

        raise ForbiddenError
      end

      def send_email
        return unless @model.persisted?

        origin = request.headers['Origin'] || request.headers['Referer']

        UserRegistrationMailer.send_email(@model.user, origin).deliver_now
      end
    end
  end
end
