# frozen_string_literal: true

class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: :authenticate

  def authenticate
    if User.authenticate(params[:email_address], params[:password])
      render json: generate_token
    else
      render json: { error: 'Credenciais inválidas.' }, status: :unauthorized
    end
  end

  def company_auth
    decoded_token = fetch_jwt
    validate_company(decoded_token)
    decoded_token.push(company_id: params[:company_id])

    render json: JWT.encode(decoded_token, 'your_secret_key', 'HS256')
  end

  private

  def generate_token
    JWT.encode({ email_address: params[:email_address] }, 'your_secret_key', 'HS256')
  end

  def fetch_jwt
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    begin
      JWT.decode(token, 'your_secret_key', true, algorithm: 'HS256')
    rescue JWT::DecodeError
      render json: { error: 'Token inválido' }, status: :unauthorized
    end
  end

  def validate_company(decoded_token)
    email_address = decoded_token.find { |token| token.key? 'email_address' }.values
    User.find_by!(email_address:).companies.find(params[:company_id])
  end
end
