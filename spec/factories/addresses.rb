FactoryBot.define do
  factory :address do
    street { Faker::Address.street_name }
    number { Faker::Address.building_number }
    neighborhood do
      "#{Faker::Address.city_prefix}#{Faker::Address.city_suffix}"
    end
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { '00000-000' }

    factory :client_address, parent: :address do
      association :addressable, factory: :client
    end

    factory :company_address, parent: :address do
      association :addressable, factory: :company
    end
  end
end
