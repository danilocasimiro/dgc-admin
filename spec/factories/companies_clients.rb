FactoryBot.define do
  factory :company_client do
    association :client
    association :company
  end
end
