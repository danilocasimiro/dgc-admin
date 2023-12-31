# frozen_string_literal: true

module JwtToken
  extend ActiveSupport::Concern

  def feth_decoded_jwt
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    begin
      jwt_token = JWT.decode(token, Figaro.env.jwt_secret, true, algorithm: 'HS256')
      jwt_token.first.is_a?(Array) ? jwt_token.first : jwt_token
    rescue JWT::DecodeError
      render json: { error: 'Necessário autenticação' }, status: :unauthorized
    end
  end

  def generate_token(user_id, email_address)
    JWT.encode({ user: { email_address:, id: user_id } }, Figaro.env.jwt_secret, 'HS256')
  end

  def user_authenticate?
    feth_decoded_jwt
  end

  def company_authenticate?
    render json: { error: 'Necessário autenticação em uma empresa' }, status: :unauthorized unless current_company_id
  end

  def current_company_id
    feth_decoded_jwt.find { |token| token.key? 'company_id' }&.values&.first
  end

  def current_user
    id = fetch_user_claim.dig('user', 'id')
    User.find(id)
  end

  def fetch_user_claim
    feth_decoded_jwt.find { |token| token.key? 'user' }
  end
end
