require 'faker'

Faker::Config.locale = 'pt-BR'

tenants = []
companies = []
product_types = []
products = []

puts 'Iniciado criação de User Admin'
tenants << Tenant.create(
  user: User.create(
    email_address: 'admin@example.com',
    password: '123456'
  ),
  name: Faker::Company.name.parameterize(separator: '_')
)
puts 'Finalizado criação de User Admin'
puts 'Iniciado criação de Tenants'
5.times do
  tenants << Tenant.create(
    user: User.create(
      email_address: Faker::Internet.email,
      password: '123456'
    ),
    name: Faker::Company.name.parameterize(separator: '_')
  )
end
puts 'Finalizado a criação de Tenants'
puts 'Iniciado a criação de Companies'
tenants.each do |tenant|
  3.times do
    company = Company.create(
      name: Faker::Company.name,
      tenant:
    )
    Address.create(
      addressable_type: 'Company',
      addressable_id: company.id,
      street: Faker::Address.street_name,
      number: Faker::Address.building_number,
      neighborhood: "#{Faker::Address.city_prefix} #{Faker::Address.city_suffix}",
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip_code: Faker::Address.zip_code
    )

    companies << company
  end
end
puts 'Finalizado a criação de Companies'
puts 'Iniciado a criação de Product Types'
companies.each do |company|
  3.times do
    product_types << ProductType.create(
      name: Faker::Commerce.department,
      company:
    )
  end
end
puts 'Finalizado a criação de Product Types'
puts 'Iniciado a criação de Products'
product_types.each do |product_type|
  3.times do
    products << Product.create(
      product_type:,
      name: Faker::Commerce.product_name,
      price: Faker::Commerce.price
    )
  end
end
puts 'Finalizado a criação de Products'
puts 'Iniciado a criação de Clients'
15.times do
  client = Client.create(
    user: User.create(
      email_address: Faker::Internet.email,
      password: '123456'
    ),
    name: Faker::Name.name
  )
  Address.create(
    addressable_type: 'Client',
    addressable_id: client.id,
    street: Faker::Address.street_name,
    number: Faker::Address.building_number,
    neighborhood: "#{Faker::Address.city_prefix} #{Faker::Address.city_suffix}",
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code
  )
  CompanyClient.create(client:, company: companies.first)
end
puts 'Finalizado a criação de Clients'