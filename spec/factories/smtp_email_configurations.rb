FactoryBot.define do
  factory :smtp_email_configuration do
    active { true }
    name { Faker::Company.name }
    address { Faker::Internet.email }
    port { 587 }
    domain { Faker::Internet.domain_name }
    user_name { Faker::Internet.email }
    password { Faker::Internet.password }
    authentication { 'plain' }
  end
end
