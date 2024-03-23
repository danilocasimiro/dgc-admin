# frozen_string_literal: true

class BaseService
  attr_accessor :company_id, :jwt_token

  def initialize(company_id = nil, jwt_token = nil)
    @company_id = company_id
    @jwt_token = jwt_token
  end

  def client
    @client ||= Faraday.new(url: Figaro.env.store_url) do |config|
      config.headers['Content-Type'] = 'application/json'
      config.options.timeout = 10
      config.options.open_timeout = 2
      config.headers['Authorization'] = jwt_token
    end
  end

  def handle_faraday_error(response)
    case response.status
    when 422
      raise UnprocessableEntityError, response.body
    when 404
      raise NotFoundError
    end
  end
end
