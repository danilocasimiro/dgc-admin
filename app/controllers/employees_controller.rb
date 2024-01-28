# frozen_string_literal: true

class EmployeesController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models =
      current_user.profile.is_a?(Tenant) ? current_user.profile.employees : current_user.profile.tenant.employees

    if current_company_id
      render json: @models.includes(:companies).where(companies: { id: current_company_id }).as_json(include: include_associations)
    else
      render json: @models.as_json(include: include_associations)
    end
  end

  def create
    @model = model_class.create!(permitted_params.merge(tenant_id: current_user.profile.id))
    create_user
    update_companies_employees

    render json: @model
  end

  def update
    @model.update!(permitted_params)
    update_user
    update_companies_employees

    render json: @model
  end

  private

  def permitted_params
    params.require(:employee)
          .permit(:name)
  end

  def companies_params
    params.permit(companies: %i[id tenant_id])
  end

  def user_params
    params.require(:user).permit(:email_address, :password)
  end

  def update_companies_employees
    return nil unless companies_params[:companies]

    @model.companies_employees.destroy_all

    companies_params[:companies].each do |company|
      CompanyEmployee.create!(company_id: company[:id], employee_id: @model.id)
    end
  end
end
