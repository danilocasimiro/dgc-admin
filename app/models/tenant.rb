# frozen_string_literal: true

class Tenant < ApplicationRecord
  belongs_to :affiliate, optional: true

  has_one :trial, inverse_of: :tenant, dependent: :destroy
  has_one :user, as: :profile, inverse_of: :profile, dependent: :destroy

  has_many :employees, inverse_of: :tenant
  has_many :companies, inverse_of: :tenant
  has_many :subscriptions, inverse_of: :tenant

  after_create :create_trial

  validates_presence_of :name

  def current_subscription
    config = SystemConfiguration.first
    subscriptions.where(status: :active).where('end_at >= ?', Time.zone.today - config.grace_period_days).first
  end

  def last_subscription
    subscriptions.last
  end

  def allow_access?
    config = SystemConfiguration.first

    Date.today < (trial.end_at + config.grace_period_days) || current_subscription
  end

  private

  def create_trial
    transaction do
      current_date = Date.today
      build_trial({ start_at: current_date, end_at: current_date.next_month }).save!
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, "Erro ao criar dado na outra tabela: #{e.message}")
      raise ActiveRecord::Rollback
    end
  end

  class << self
    def relation_map
      %i[companies user]
    end
  end
end
