FactoryBot.define do
  factory :subscription do
    association :tenant
    association :subscription_plan
    status { 0 }
    start_at { Faker::Date.between(from: 10.years.ago, to: Date.today) }
    end_at { nil }
  end
end
