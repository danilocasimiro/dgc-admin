# frozen_string_literal: true

class CompanyService < BaseService
  def create_company(data)
    response =
      client.post('/api/v1/companies', data.to_json)

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end
end
