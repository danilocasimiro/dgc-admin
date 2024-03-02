# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      include Concerns::UserContext

      before_action :set_resource, only: %i[show update]
      before_action :user_authenticate?, :allow_access?, except: %i[activate password_recovery update_password]

      def show
        return raise ForbiddenError unless user_has_permission?

        if @model.admin?
          render json: { user: @model.as_json }
        else
          render json: @model.profile.as_json(include: :user)
        end
      end

      def update
        return raise ForbiddenError unless user_has_permission?

        @model.update!(permitted_params.reject { |_, value| value.blank? })
        @model.profile.update!(profile_params) if @model.profile && profile_params

        render json: @model
      end

      def activate
        validator = Validation.find_by!(
          user_id: activate_params[:user_id],
          token: activate_params[:token],
          validation_type: activate_params[:validation_type],
          status: 0
        )

        validator.update!(status: 2)
        validator.user.update!(status: 0)

        head :ok
      end

      def password_recovery
        @model = User.find_by!(email_address: password_recovery_params[:email_address])
        @model.validations.where(validation_type: 1).tap do |validation|
          validation.update!(status: 1)
        end

        validator = create_validator
        send_email(validator.token)

        head :ok
      end

      def update_password
        validator = Validation.find_by!(
          user_id: update_password_params[:user_id],
          validation_type: 1,
          status: 0
        )
        validator.user.update!(password: update_password_params[:password])
        validator.update!(status: 2)

        head :ok
      end

      private

      def permitted_params
        params.require(:user).permit(:email_address, :password)
      end

      def activate_params
        params.permit(:token, :user_id, :validation_type)
      end

      def password_recovery_params
        params.permit(:email_address)
      end

      def update_password_params
        params.permit(:user_id, :password, :token)
      end

      def profile_params
        params.permit(:name)
      end

      def send_email(token)
        origin = request.headers['Origin'] || request.headers['Referer']

        UserPasswordRecoveryMailer.send_email(@model, origin, token).deliver_now
      end

      def create_validator
        Validation.create!(
          user_id: @model.id,
          token: SecureRandom.hex(20),
          validation_type: 1,
          status: 0
        )
      end

      def user_has_permission?
        current_user.admin? || current_user.id == params[:id].to_i
      end
    end
  end
end
