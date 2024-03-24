# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      before_action :user_authenticate, only: :authenticate

      def authenticate
        if !@user
          render_error('Credenciais inválidas.')
        elsif !@user.active?
          send_email
          render_error(I18n.t('authenticate.inactive_user', user_email: params[:email_address]))
        else
          render json: Concerns::JwtToken.generate_token(@user)
        end
      end

      def company_auth
        decoded_token = feth_decoded_jwt
        validate_company

        user = User.find(decoded_token&.first&.dig('user', 'id'))

        render json: Concerns::JwtToken.generate_token(user,
                                                       params[:company_id])
      end

      def logout_company_auth
        decoded_token = feth_decoded_jwt

        user = User.find(decoded_token&.first&.dig('user', 'id'))

        render json: Concerns::JwtToken.generate_token(user)
      end

      private

      def user_authenticate
        @user = User.authenticate(params[:email_address], params[:password])
      end

      def validate_company
        current_user.profile.companies.find(params[:company_id])
      end

      def send_email
        origin = request.headers['Origin'] || request.headers['Referer']
        UserRegistrationMailer.send_email(@user, origin).deliver_now
      end

      def render_error(error_msg)
        render json: { error: error_msg }, status: :unauthorized
      end
    end
  end
end
