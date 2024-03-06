# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Concerns::PaginationSerializer

      def show
        render json: @model.as_json(include: include_associations)
      end

      def create
        @model = model_class.create!(permitted_params)

        render json: @model
      end

      def update
        @model.update!(permitted_params)

        render json: @model
      end

      def destroy
        @model.destroy!
        head :ok
      end

      private

      def model_class
        controller_name.classify.constantize
      end

      def create_user
        user = @model.build_user(user_params.reject { |_, value| value.blank? })
        user.save!
      end

      def update_user
        return unless params[:user]

        @model.user.update!(user_params.reject do |_, value|
                              value.blank?
                            end)
      end

      def store_address
        return unless addressable_params.present?

        Address.create!(
          addressable_params[:address]
          .merge({ addressable_id: @model.id,
                   addressable_type: @model.class.name })
        )
      end

      def set_resource
        @model = model_class.find(params[:id])
      end

      def update_address
        return unless addressable_params

        if @model.address
          @model.address.update!(addressable_params[:address])
        else
          store_address
        end
      end

      def user_params
        throw NotImplementedError
      end

      def addressable_params
        params.permit(address: %i[street number neighborhood city state
                                  zip_code])
      end

      def include_associations
        return unless params[:expand]

        expand_params = params[:expand].split(',').map(&:to_sym)
        model_class.relation_map.select { |item| expand_params.include?(item) }
      end

      def user_has_permission?
        current_user.admin? || current_user.profile_id == params[:id].to_i
      end
    end
  end
end
