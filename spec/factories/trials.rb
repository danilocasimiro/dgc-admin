FactoryBot.define do
  factory :trial do
    association :tenant
    start_at { Faker::Date.between(from: 10.years.ago, to: Date.today) }
    end_at { Faker::Date.between(from: Date.tomorrow, to: 1.year.from_now) }
  end
end
