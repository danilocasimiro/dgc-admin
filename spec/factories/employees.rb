FactoryBot.define do
  factory :employee do
    name { Faker::Name.name }
    association :tenant
  end
end
