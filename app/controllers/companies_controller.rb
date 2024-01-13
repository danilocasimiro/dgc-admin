# frozen_string_literal: true

class CompaniesController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show destroy update]

  def index
    @models = model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def update
    if @model.update(company_params)
      if addressable_params
        @model.address ? @model.address.update(addressable_params) : store_address
      end

      render json: @model
    else
      render json: errors
    end
  end

  def create
    @model = model_class.new(company_params)

    if @model.save
      store_address
      render json: @model
    else
      render json: errors
    end
  end

  def destroy
    @model.destroy

    if @model.errors.present?
      render json: errors
    else
      head :ok
    end
  end

  private

  def set_resource
    @model = Company.with_user_id(current_user.id).find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name).merge(tenant_id: current_user.id)
  end

  def addressable_params
    params.permit(:street, :number, :neighborhood, :city, :state, :zip_code)
  end

  def store_address
    if addressable_params.present?
      Address.create(
        addressable_params.merge({ addressable_id: @model.id, addressable_type: 'Company' })
      )
    end
  end
end
