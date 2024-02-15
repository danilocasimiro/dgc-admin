FactoryBot.define do
  factory :company_email_template do
    association :email_template
    association :company
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
  end
end
