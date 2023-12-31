# frozen_string_literal: true

class AddressableController < BaseController
  def create_address
    @model = Address.new(addressable_params)

    if @model.save
      render json: @model
    else
      render json: errors
    end
  end

  def update_address
    @model = Address.where(id: params[:address_id], addressable_id: params[:company_id], addressable_type: model_class)
    if @model.update(addressable_params)
      render json: @model
    else
      render json: errors
    end
  end

  private

  def addressable_params
    raise NotImplementedError, 'O método addressable_params deve ser implementado nas classes filhas.'
  end
end
