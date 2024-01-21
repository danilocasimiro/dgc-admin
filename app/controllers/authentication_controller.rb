# frozen_string_literal: true

class AuthenticationController < ApplicationController
  def authenticate
    user = User.authenticate(params[:email_address], params[:password])
    if !user
      render json: { error: 'Credenciais inválidas.' }, status: :unauthorized
    else
      render json: generate_token(user)
    end
  end

  def company_auth
    validate_company
    decoded_token = feth_decoded_jwt

    user = User.find(decoded_token&.first&.dig('user', 'id'))

    render json: generate_token(user, params[:company_id])
  end

  private

  def validate_company
    current_user.profile.companies.find(params[:company_id])
  end
end
