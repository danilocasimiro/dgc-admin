FactoryBot.define do
  factory :company_employee do
    association :company
    association :employee
  end
end
