FactoryBot.define do
  factory :company do
    association :tenant
    name { Faker::Name.name }
  end
end
