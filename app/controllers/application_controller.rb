# frozen_string_literal: true

class ApplicationController < ActionController::API
  include JwtToken

  around_action :wrap_in_transaction

  def wrap_in_transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end
end
