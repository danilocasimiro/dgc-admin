# frozen_string_literal: true

class ClientsController < BaseController
  include CompanyContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models.as_json(include: include_associations)
  end

  def create
    @model = model_class.create!(permitted_params)
    create_user
    store_address
    associate_with_company

    render json: @model
  end

  def update
    @model.update!(permitted_params)
    update_user
    update_address

    render json: @model
  end

  private

  def user_params
    params.permit(:email_address, :password)
  end

  def client_params
    params.require(:client).permit(:name)
  end

  def set_resource
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def associate_with_company
    @model.associate_with_company(current_company_id)
  end
end
