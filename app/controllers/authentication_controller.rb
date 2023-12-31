# frozen_string_literal: true

class AuthenticationController < ApplicationController
  def authenticate
    user = User.authenticate(params[:email_address], params[:password])
    if user
      render json: generate_token(user.id, params[:email_address])
    else
      render json: { error: 'Credenciais inválidas.' }, status: :unauthorized
    end
  end

  def company_auth
    validate_company
    decoded_token = feth_decoded_jwt
    decoded_token.push(company_id: params[:company_id])

    render json: JWT.encode(decoded_token, Figaro.env.jwt_secret, 'HS256')
  end

  private

  def validate_company
    current_user.companies.find(params[:company_id])
  end
end
