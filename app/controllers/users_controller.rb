# frozen_string_literal: true

class UsersController < BaseController
  include UserContext

  before_action :set_resource, only: :show

  def show
    render json: @model.as_json(include: include_associations)
  end

  private

  def set_resource
    @model = model_class.find(params[:id])
  end
end
