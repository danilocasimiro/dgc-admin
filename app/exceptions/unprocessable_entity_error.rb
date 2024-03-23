# frozen_string_literal: true

class UnprocessableEntityError < StandardError
  def initialize(message = 'Erro ao salvar este model.')
    super(message)
  end
end
