# frozen_string_literal: true

module HandleErrors
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_record_not_destroyed
    rescue_from ActiveRecord::RecordNotSaved, with: :handle_record_not_saved
  end

  private

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
end