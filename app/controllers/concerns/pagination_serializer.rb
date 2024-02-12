# frozen_string_literal: true

module PaginationSerializer
  extend ActiveSupport::Concern

  PER_PAGE=10

  def paginate(collection)
    if params[:before].present?
      collection.where("#{collection.table_name}.id < ?", params[:before]).order(id: :desc).limit(PER_PAGE).as_json(include: include_associations)
    elsif params[:after].present?
      collection.where("#{collection.table_name}.id > ?", params[:after]).order(:id).limit(PER_PAGE).as_json(include: include_associations)
    else
      collection.order(:id).limit(PER_PAGE).as_json(include: include_associations)
    end
  end
end