# frozen_string_literal: true

class ProductTypeService < BaseService
  def fetch_product_types(query_params = {})
    response = client.get("/api/v1/companies/#{company_id}/product_types", query_params)

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def fetch_product_type(product_type_id, query_params = {})
    response = client.get("/api/v1/companies/#{company_id}/product_types/#{product_type_id}", query_params)

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def update_product_type(product_type_id, data)
    response =
      client.put(
        "/api/v1/companies/#{company_id}/product_types/#{product_type_id}", data.to_json
      )

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def destroy_product_type(product_type_id)
    response =
      client.delete("/api/v1/companies/#{company_id}/product_types/#{product_type_id}")

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def create_product_type(data)
    response =
      client.post(
        "/api/v1/companies/#{company_id}/product_types", data.to_json
      )

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end
end
