require 'faker'

Faker::Config.locale = 'pt-BR'

tenants = []
companies = []
product_types = []
products = []


puts 'Iniciado criação de User Admin'
User.create!(
  status: 0,
  email_address: 'admin@sistema.com',
  password: '123456'
)
puts 'Finalizado criação de User Admin'
puts 'Iniciado criação do Tenant Teste'
tenant = Tenant.create!(
  name: Faker::Company.name.parameterize(separator: '_')
)
User.create!(
  profile_type: 'Tenant',
  profile_id: tenant.id,
  status: 0,
  email_address: 'tenant@sistema.com',
  password: '123456'
)
puts 'Finalizado criação do Tenant Teste'
puts 'Iniciado criação da Empresa Teste'
company = Company.create!(
  name: Faker::Company.name,
  tenant:
)
Address.create!(
  addressable_type: 'Company',
  addressable_id: company.id,
  street: Faker::Address.street_name,
  number: Faker::Address.building_number,
  neighborhood: "#{Faker::Address.city_prefix} #{Faker::Address.city_suffix}",
  city: Faker::Address.city,
  state: Faker::Address.state_abbr,
  zip_code: Faker::Address.zip_code
)
puts 'Finalizado criação da Empresa Teste'
puts 'Iniciado criação da Empregados Teste'
  employee = Employee::create!(
    tenant_id: tenant.id,
    name: Faker::Name.name
  )
  User.create!(
    profile_type: 'Employee',
    profile_id: employee.id,
    status: 0,
    email_address: 'company_employee@sistema.com',
    password: '123456'
  )
  CompanyEmployee.create!(
    employee_id: employee.id,
    company_id: company.id
  )
  employee = Employee::create!(
    tenant_id: tenant.id,
    name: Faker::Name.name
  )
  User.create!(
    profile_type: 'Employee',
    profile_id: employee.id,
    status: 0,
    email_address: 'tenant_employee@sistema.com',
    password: '123456'
  )
  CompanyEmployee.create!(
    employee_id: employee.id,
    company_id: company.id
  )
puts 'Finalizado criação da Empregados Teste'
puts 'Iniciando criação dos Planos iniciais'
SubscriptionPlan.create!(
  name: 'Plano Mensal',
  description: 'Ativação do sistema por 1 mês',
  activation_months: 1,
  price: 50.00
)
SubscriptionPlan.create!(
  name: 'Plano Semestral',
  description: 'Ativação do sistema por 6 meses',
  activation_months: 6,
  price: 85.00
)
SubscriptionPlan.create!(
  name: 'Plano Anual',
  description: 'Ativação do sistema por 1 ano',
  activation_months: 12,
  price: 100.00
)
puts 'Finalizado criação da Empregados Teste'
puts 'Iniciado criação da Configuração do serviço de email do sistema'
  smtp_email_config = SmtpEmailConfiguration.create!(
    active:               true,
    name:                 Figaro.env.service_email_name,
    address:              Figaro.env.service_email_domain,
    port:                 587,
    domain:               Figaro.env.service_email_domain,
    user_name:            Figaro.env.service_email_user_name,
    password:             Figaro.env.service_email_password,
    authentication:       'plain',
  )
puts 'Finalizado criação da Configuração do serviço de email do sistema'
puts 'Iniciado criação da Configuração inicial do sistema'
  SystemConfiguration.create!(
    smtp_email_configuration_id: smtp_email_config.id
  )
puts 'Finalizado criação da Configuração inicial do sistema'
puts 'Iniciado criação de templates de email do sistema'
  user_email_template = EmailTemplate.create!(
    action: 'user_register',
    subject: 'Confirmação de registro no sistema Ecommerce.',
    body: '<p>Olá {{nome_do_usuario}}!!!</p><p>Clique no link abaixo para confirmar seu cadastro no sistema Ecommerce</p><p>{{link_para_ativacao_registro}}</p>',
    allow_variables: 'nome_do_usuario | link_para_ativacao_registro'
  )
  user_password_recovery_template = EmailTemplate.create!(
    action: 'password_recovery',
    subject: 'Recuperação de senha no sistema Ecommerce.',
    body: '<p>Olá {{nome_do_usuario}}!!!</p><p>Clique no link abaixo para cadastrar uma nova senha para sua conta no sistema Ecommerce</p><p>{{link_para_atualizar_senha}}</p>',
    allow_variables: 'nome_do_usuario | link_para_atualizar_senha'
  )
  employee_email_template = EmailTemplate.create!(
    action: 'employee_register',
    subject: 'Registro de colaborador no sistema Ecommerce.',
    body: '<p>Olá {{nome_do_usuario}}!!!</p><p>Você foi registrado por {{tenant_email_address}} no sistema Ecommerce<p>Clique no link abaixo para confirmar seu cadastro</p><p>{{link_para_ativacao_registro}}</p>',
    allow_variables: 'nome_do_usuario | link_para_ativacao_registro | tenant_email_address'
  )
puts 'Finalizado criação de templates de email do sistema'
puts 'Iniciado criação de templates de email da empresa'
  CompanyEmailTemplate.create!(
    company_id: company.id,
    email_template_id: user_email_template.id,
    subject: user_email_template.subject,
    body: user_email_template.body
  )
  CompanyEmailTemplate.create!(
    company_id: company.id,
    email_template_id: employee_email_template.id,
    subject: employee_email_template.subject,
    body: employee_email_template.body
  )
  CompanyEmailTemplate.create!(
    company_id: company.id,
    email_template_id: user_password_recovery_template.id,
    subject: user_password_recovery_template.subject,
    body: user_password_recovery_template.body
  )
puts 'Finalizado criação de templates de email da empresa'
# tenants << Tenant.create(
#   user: User.create(
#     email_address: 'admin@example.com',
#     password: '123456'
#   ),
#   name: Faker::Company.name.parameterize(separator: '_')
# )

# puts 'Iniciado criação de Tenants'
# 5.times do
#   tenants << Tenant.create(
#     user: User.create(
#       email_address: Faker::Internet.email,
#       password: '123456'
#     ),
#     name: Faker::Company.name.parameterize(separator: '_')
#   )
# end
# puts 'Finalizado a criação de Tenants'
# puts 'Iniciado a criação de Companies'
# tenants.each do |tenant|
#   3.times do
#     company = Company.create(
#       name: Faker::Company.name,
#       tenant:
#     )
#     Address.create(
#       addressable_type: 'Company',
#       addressable_id: company.id,
#       street: Faker::Address.street_name,
#       number: Faker::Address.building_number,
#       neighborhood: "#{Faker::Address.city_prefix} #{Faker::Address.city_suffix}",
#       city: Faker::Address.city,
#       state: Faker::Address.state_abbr,
#       zip_code: Faker::Address.zip_code
#     )

#     companies << company
#   end
# end
# puts 'Finalizado a criação de Companies'
# puts 'Iniciado a criação de Product Types'
# companies.each do |company|
#   3.times do
#     product_types << ProductType.create(
#       name: Faker::Commerce.department,
#       company:
#     )
#   end
# end
# puts 'Finalizado a criação de Product Types'
# puts 'Iniciado a criação de Products'
# product_types.each do |product_type|
#   3.times do
#     products << Product.create(
#       product_type:,
#       name: Faker::Commerce.product_name,
#       price: Faker::Commerce.price
#     )
#   end
# end
# puts 'Finalizado a criação de Products'
# puts 'Iniciado a criação de Clients'
# 15.times do
#   client = Client.create(
#     user: User.create(
#       email_address: Faker::Internet.email,
#       password: '123456'
#     ),
#     name: Faker::Name.name
#   )
#   Address.create(
#     addressable_type: 'Client',
#     addressable_id: client.id,
#     street: Faker::Address.street_name,
#     number: Faker::Address.building_number,
#     neighborhood: "#{Faker::Address.city_prefix} #{Faker::Address.city_suffix}",
#     city: Faker::Address.city,
#     state: Faker::Address.state_abbr,
#     zip_code: Faker::Address.zip_code
#   )
#   CompanyClient.create(client:, company: companies.first)
# end
# puts 'Finalizado a criação de Clients'
