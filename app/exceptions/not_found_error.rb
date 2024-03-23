# frozen_string_literal: true

class NotFoundError < StandardError
  def initialize(message = 'Entidade não encontrada.')
    super(message)
  end
end
