# frozen_string_literal: true

class ClientsController < AddressableController
  include CompanyContext

  def index
    @models = Client.with_company_id(current_company_id)

    render json: @models
  end

  def create
    super
    client = Client.create!(client_params.merge(user_id: @model.id))
    client.associate_with_company(current_company_id)
  end

  def model_params
    params.permit(:email_address, :password)
  end

  def model_class
    User
  end

  def model
    @model = Client.with_company_id(current_company_id).find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name)
  end

  def addressable_params
    params
      .permit(:street, :number, :neighborhood, :city, :state)
      .merge({ addressable_id: params[:client_id], addressable_type: 'Client' })
  end
end
