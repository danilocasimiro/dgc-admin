FactoryBot.define do
  factory :menu do
    label { 'any_menu' }
    link { '#' }
    icon { nil }
    company { 0 }
    users_allowed { 'tenant | admin | employee | client | affiliate' }
  end
end
