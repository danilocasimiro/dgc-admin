FactoryBot.define do
  factory :email_template do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    allow_variables { 'first_variable | second_variable | third_variable' }
  
    factory :user_register_email_template_action do
      action { 'user_register' }
    end

    factory :password_recovery_email_template_action do
      action { 'password_recovery' }
    end

    factory :employee_register_email_template_action do
      action { 'employee_register' }
    end
  end
end
