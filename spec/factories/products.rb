FactoryBot.define do
  factory :product do
    association :product_type
    name { Faker::Name.name }
    price { Faker::Commerce.price }
  end
end
