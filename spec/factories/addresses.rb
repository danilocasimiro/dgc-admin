FactoryBot.define do
  factory :address do
    street: Faker::Address.street_name
    number: Faker::Address.building_number
    neighborhood: "#{Faker::Address.city_prefix} #{Faker::Address.city_suffix}"
    city: Faker::Address.city
    state: Faker::Address.state_abbr
    zip_code: Faker::Address.zip_code

      factory :client_address do
        association :profile, factory: :client
      end

      factory :company_address do
        association :profile, factory: :company
      end
  end
end
