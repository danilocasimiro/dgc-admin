# frozen_string_literal: true

class BaseController < ApplicationController
  def model_class
    controller_name.classify.constantize
  end

  private

  def errors
    {
      model: @model.class,
      errors: @model.errors.full_messages
    }
  end

  def include_associations
    return unless params[:expand]

    expand_params = params[:expand].split(',').map(&:to_sym)
    model_class.relation_map.select { |item| expand_params.include?(item) }
  end
end
