# frozen_string_literal: true

class UserService < BaseService
  def create_user(data)
    response =
      client.post('/api/v1/users', { user: data }.to_json)

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end
end
