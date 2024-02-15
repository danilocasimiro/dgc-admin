FactoryBot.define do
  factory :subscription_plan do
    name { Faker::Name.name }
    activation_months { Faker::Number.between(from: 1, to: 100) }
    price { Faker::Commerce.price }
  end
end
