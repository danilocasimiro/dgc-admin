FactoryBot.define do
  factory :client do
    name { Faker::Name.name }
  end
end
