FactoryBot.define do
  factory :user do
      friendly_id { "#{rand(100)}" }
      email_address { Faker::Internet.email }
      password_digest { '123456' }
      status: 0

      factory :client_user do
        association :profile, factory: :client
      end
  
      factory :tenant_user do
        association :profile, factory: :tenant
      end
  
      factory :employee_user do
        association :profile, factory: :employee
      end
  end
end
