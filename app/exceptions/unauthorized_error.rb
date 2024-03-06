# frozen_string_literal: true

class UnauthorizedError < StandardError
  def initialize(message = 'Você não tem permissão para acessar esta ação.')
    super(message)
  end
end
