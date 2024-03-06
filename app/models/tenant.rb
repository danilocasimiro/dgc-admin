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

  scope :accessible_by_user, lambda { |user|
                               case user.type.to_s
                               when 'Admin'
                                 all
                               when 'Affiliate'
                                 where(affiliate_id: user.profile_id)
                               else
                                 raise ForbiddenError
                               end
                             }

  def current_subscription
    conf = SystemConfiguration.first
    subscriptions.where(status: :active)
                 .where('end_at >= ?', Time.zone.today - conf.grace_period_days)
                 .first
  end

  def last_subscription
    subscriptions.last
  end

  def allow_access?
    conf = SystemConfiguration.first

    Date.today < (trial.end_at + conf.grace_period_days) || current_subscription
  end

  private

  def create_trial
    transaction do
      current_date = Date.today
      build_trial({ start_at: current_date, end_at: current_date.next_month })
        .save!
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
