FactoryBot.define do
  factory :product_type do
    association :company
    name { Faker::Name.name }
  end
end
