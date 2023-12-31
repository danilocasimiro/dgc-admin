# frozen_string_literal: true

class ClientsController < AddressableController
  def create
    super
    @model.associate_with_company(company_id_param) if @model.valid?
  end

  def model_params
    params.require(:client).permit(:name, :email_address, :company_id)
  end

  def company_id_param
    params.require(:company_id)
  end

  def addressable_params
    params
      .permit(:street, :number, :neighborhood, :city, :state)
      .merge({ addressable_id: params[:client_id], addressable_type: 'Client' })
  end
end
