# frozen_string_literal: true

class ProductService < BaseService
  def fetch_products
    response = client.get("/api/v1/companies/#{company_id}/products")

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def update_product(product_id, data)
    response =
      client.put(
        "/api/v1/companies/#{company_id}/products/#{product_id}", data.to_json
      )

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def destroy_product(product_id)
    response =
      client.delete("/api/v1/companies/#{company_id}/products/#{product_id}")

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end

  def create_product(data)
    response =
      client.post(
        "/api/v1/companies/#{company_id}/products", data.to_json
      )

    if response.success?
      response.body
    else
      handle_faraday_error(response)
    end
  end
end
