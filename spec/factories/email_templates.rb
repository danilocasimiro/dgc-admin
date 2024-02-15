FactoryBot.define do
  factory :email_template do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    allow_variables { 'first_variable | second_variable | third_variable' }
    name { Faker::Name.name }
  
    factory :user_register_action do
      action { 'user_register' }
    end

    factory :password_recovery_action do
      action { 'password_recovery' }
    end

    factory :employee_register_action do
      action { 'employee_register' }
    end
  end
end
