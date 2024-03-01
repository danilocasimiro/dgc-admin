FactoryBot.define do
  factory :client do
    name { Faker::Name.name }

    association :address, strategy: :build
    association :user, strategy: :build
  end
end
