# frozen_string_literal: true

class BaseController < ApplicationController
  before_action :model, only: %i[show update destroy]

  def index
    @models = model_class.all

    render json: @models
  end

  def show
    render json: @model
  end

  def update
    if @model.update(model_params)
      render json: @model
    else
      render json: errors
    end
  end

  def create
    @model = model_class.new(model_params)

    if @model.save
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

  def model_params
    raise NotImplementedError, 'O método model_params deve ser implementado nas classes filhas.'
  end

  def model_class
    controller_name.classify.constantize
  end

  def model
    @model = model_class.find(params[:id])
  end

  def errors
    {
      model: @model.class,
      errors: @model.errors.full_messages
    }
  end
end
