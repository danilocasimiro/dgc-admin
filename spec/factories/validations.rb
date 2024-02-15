FactoryBot.define do
  factory :validation do
    association :user
    status { 0 }
    token { SecureRandom.hex(20) }

    factory :registration_validations do
      validation_type { 0 }
    end

    factory :password_recovery_validations do
      validation_type { 1 }
    end
  end
end
