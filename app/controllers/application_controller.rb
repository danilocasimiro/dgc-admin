# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    begin
      decoded = JWT.decode(token, 'your_secret_key', true, algorithm: 'HS256')
      @current_user = User.find_by(email_address: decoded.first['email_address'])
    rescue JWT::DecodeError
      render json: { error: 'Token inválido' }, status: :unauthorized
    end
  end
end
