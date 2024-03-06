# frozen_string_literal: true

module Api
  module V1
    class TenantsController < BaseController
      include Concerns::UserContext

      before_action :allow_access?, except: %i[create]
      before_action :user_has_permission_to_create?, only: :create
      before_action :set_resource, only: %i[show update destroy]

      def index
        @models = model_class.accessible_by_user(current_user)

        render json: paginate(@models)
      end

      def create
        tenant_data =
          permitted_params.slice(*model_class.column_names.map(&:to_sym))
        if current_user.affiliate?
          tenant_data[:affiliate_id] = current_user.profile_id
        end

        @model = model_class.create!(tenant_data)
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
        params.require(:tenant).permit(:name)
      end

      def user_has_permission_to_create?
        return false if current_user.admin? || current_user.affiliate?

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
