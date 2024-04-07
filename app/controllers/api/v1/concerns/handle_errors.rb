# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module HandleErrors
        extend ActiveSupport::Concern

        included do
          rescue_from ActiveRecord::RecordNotFound,
                      with: :handle_record_not_found
          rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
          rescue_from ActiveRecord::RecordNotDestroyed,
                      with: :handle_record_not_destroyed
          rescue_from ActiveRecord::RecordNotSaved,
                      with: :handle_record_not_saved
          rescue_from ForbiddenError, with: :handle_forbidden_error
          rescue_from UnauthorizedError, with: :handle_unauthorized
          rescue_from NotFoundError, with: :handle_record_not_found
          rescue_from BadRequestError, with: :handle_bad_request
          rescue_from UnprocessableEntityError,
                      with: :handle_unprocessable_entity
        end

        private

        def handle_unprocessable_entity(exception)
          error_message = JSON.parse(exception.message)
          response.headers['X-Error-Message'] = error_message
          render json: error_message, status: :unprocessable_entity
        end

        def handle_bad_request(exception)
          error_message = exception.message
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :bad_request
        end

        def handle_unauthorized(exception)
          error_message = exception.message
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :unauthorized
        end

        def handle_record_not_found(exception)
          error_message = exception.message
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :not_found
        end

        def handle_record_invalid(exception)
          error_message = exception.record.errors.full_messages.join(', ')
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :unprocessable_entity
        end

        def handle_record_not_destroyed(exception)
          error_message = exception.message
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :unprocessable_entity
        end

        def handle_record_not_saved(exception)
          error_message = exception.message
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :unprocessable_entity
        end

        def handle_forbidden_error(exception)
          error_message = exception.message
          response.headers['X-Error-Message'] = error_message
          render json: { error: error_message }, status: :forbidden
        end
      end
    end
  end
end
