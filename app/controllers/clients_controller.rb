# frozen_string_literal: true

class ClientsController < BaseController
  include CompanyContext

  after_action :create_user, :store_address, :associate_with_company, only: :create
  after_action :update_user, :update_address, only: :update
  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models.as_json(include: include_associations)
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
