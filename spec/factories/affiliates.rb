FactoryBot.define do
  factory :affiliate do
    name { Faker::Name.name }
    association :user
  end
end
