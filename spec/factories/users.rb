FactoryBot.define do
  factory :user do
    friendly_id { rand(100).to_s }
    email_address { Faker::Internet.email }
    password { '123456' }
    status { 0 }

    factory :client_user do
      association :profile, factory: :client
    end

    factory :tenant_user do
      association :profile, factory: :tenant
    end

    factory :employee_user do
      association :profile, factory: :employee
    end

    factory :affiliate_user do
      association :profile, factory: :affiliate
    end
  end
end
