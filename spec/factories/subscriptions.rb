FactoryBot.define do
  factory :subscription do
    association :tenant
    association :subscription_plan
    status { :active }
    start_at { Faker::Date.between(from: 10.years.ago, to: Date.today) }
    end_at { nil }
  end
end
