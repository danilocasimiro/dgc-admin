# frozen_string_literal: true

class AuthenticationController < ApplicationController
  def authenticate
    user = User.authenticate(params[:email_address], params[:password])
    if !user
      render json: { error: 'Credenciais inválidas.' }, status: :unauthorized
    elsif !user.active?
      origin = request.headers['Origin'] || request.headers['Referer']
      UserRegistrationMailer.send_email(user, origin).deliver_now
      render json: { error: "Usuário inativo. Um novo email foi encaminhado para #{params[:email_address]} para realizar a ativação de sua conta." }, status: :unauthorized
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

  def logout_company_auth
    decoded_token = feth_decoded_jwt

    user = User.find(decoded_token&.first&.dig('user', 'id'))

    render json: generate_token(user)
  end

  private

  def validate_company
    current_user.profile.companies.find(params[:company_id])
  end
end
