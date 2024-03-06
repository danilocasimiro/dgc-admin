# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module PaginationSerializer
        extend ActiveSupport::Concern

        PER_PAGE = 10

        def paginate(collection)
          @collection = collection
          total_pages
          return before if params[:before].present?

          return after if params[:after].present?

          collection.order(:id).limit(PER_PAGE)
                    .as_json(include: include_associations)
        end

        def before
          @collection.where("#{@collection.table_name}.id < ?",
                            params[:before])
                     .order(id: :desc)
                     .limit(PER_PAGE)
                     .as_json(include: include_associations).reverse!
        end

        def after
          return unless params[:after].present?

          @collection.where("#{@collection.table_name}.id > ?",
                            params[:after])
                     .order(:id)
                     .limit(PER_PAGE)
                     .as_json(include: include_associations)
        end

        def total_pages
          collection_length =
            @collection.respond_to?(:count) ? @collection.count : 0

          response.headers['Total-Pages'] =
            if collection_length.positive?
              (collection_length.to_f / PER_PAGE).ceil
            else
              0
            end
        end
      end
    end
  end
end
