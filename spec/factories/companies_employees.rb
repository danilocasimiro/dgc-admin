FactoryBot.define do
  factory :company_client do
    association :company
    association :employee
  end
end
