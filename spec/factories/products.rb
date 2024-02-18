FactoryBot.define do
  factory :product do
    name { Faker::Name.name }
    price { Faker::Commerce.price }
    association :product_type
  end
end
