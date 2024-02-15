FactoryBot.define do
  factory :tenant do
    name { Faker::Name.name }
  end
end
