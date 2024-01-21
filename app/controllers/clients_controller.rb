# frozen_string_literal: true

class ClientsController < BaseController
  include CompanyContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def update
    if @model.update(client_params)
      if addressable_params
        @model.address ? @model.address.update(addressable_params) : store_address
      end

      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def create
    @user = User.create!(user_params)
    @model = model_class.new(client_params.merge(user_id: @user.id))

    if @model.save && @model.associate_with_company(current_company_id)
      store_address
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def destroy
    @model.destroy

    if @model.errors.present?
      render json: { errors: }, status: :bad_request
    else
      head :ok
    end
  end

  private

  def user_params
    params.permit(:email_address, :password)
  end

  def client_params
    params.require(:client).permit(:name)
  end

  def set_resource
    @climodelent = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def addressable_params
    params.permit(:street, :number, :neighborhood, :city, :state, :zip_code)
  end

  def store_address
    return unless addressable_params.present?

    Address.create(
      addressable_params.merge({ addressable_id: @model.id, addressable_type: 'Company' })
    )
  end
end
