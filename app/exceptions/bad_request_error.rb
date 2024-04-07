# frozen_string_literal: true

class BadRequestError < StandardError
  def initialize(message = 'Parâmetros inválidos.')
    super(message)
  end
end
