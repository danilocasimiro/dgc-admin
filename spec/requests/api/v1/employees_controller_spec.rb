# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'EmployeesController', type: :request do
      let(:token) { Concerns::JwtToken.generate_token(user, company_id) }
      let(:company) { create(:company) }
      let(:company_id) { company.id }

      describe 'GET #index' do
        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            before do
              create_list(:employee, 1)

              get '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }
            end

            it "returns a forbidden response" do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is a tenant' do
            let(:employee) { create(:employee, tenant_id: user.profile.id) }
            let(:user) { create(:tenant_user) }

            before do
              create(:employee, tenant_id: user.profile.id)
              create(:employee, tenant_id: user.profile.id)
              create(:company_employee, employee: employee, company:)
            end

            context 'when user is logged in company' do
              before do
                get '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }
              end

              it "returns a success response" do
                expect(response).to have_http_status(:success)
              end

              it "returns JSON response with paginated models" do
                expect(response).to be_successful
                expect(JSON.parse(response.body).size).to eq(1)
              end
            end

            context 'when user is not logged in company' do
              let(:company_id) { nil }

              before do
                get '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }
              end

              it "returns a success response" do
                expect(response).to have_http_status(:success)
              end

              it "returns JSON response with paginated models" do
                expect(response).to be_successful
                expect(JSON.parse(response.body).size).to eq(3)
              end
            end
          end

          context 'when user is a employee' do
            let(:employee) { create(:employee, tenant_id: user.profile.tenant.id) }
            let(:user) { create(:employee_user) }

            before do
              create(:employee, tenant_id: user.profile.tenant.id)
              create(:employee, tenant_id: user.profile.tenant.id)
              create(:company_employee, employee: employee, company:)
            end

            context 'when user is logged in company' do
              before do
                get '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }
              end

              it "returns a success response" do
                expect(response).to have_http_status(:success)
              end

              it "returns JSON response with paginated models" do
                expect(response).to be_successful
                expect(JSON.parse(response.body).size).to eq(1)
              end
            end

            context 'when user is not logged in company' do
              let(:company_id) { nil }

              before do
                get '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }
              end

              it "returns a success response" do
                expect(response).to have_http_status(:success)
              end

              it "returns JSON response with paginated models" do
                expect(response).to be_successful
                expect(JSON.parse(response.body).size).to eq(4)
              end
            end
          end
        end

        context 'when user is not logger in' do
          before do
            get '/api/v1/employees'
          end

          it "returns a unauthorized response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'POST #create' do
        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:employee_params) { attributes_for(:employee) }
            let(:user_registration_mailer) { double('UserRegistrationMailer') }
            let(:user_data) do 
              { 
                email_address: 'any_email@example.com', password: 'any_password'
              }
            end

            before do
              expect(UserRegistrationMailer).to receive(:send_email).and_return(user_registration_mailer)
              expect(user_registration_mailer).to receive(:deliver_now).and_return(true)

              post '/api/v1/employees', params: { employee: employee_params, user: user_data }, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'creates a new employee' do
              expect(response).to have_http_status(:ok)
              employee = Employee.last
              expect(employee.name).to eq(employee_params[:name])
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }

            it 'returns a forbidden response' do
              post '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              post '/api/v1/employees', headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            post '/api/v1/employees'
          end

          it "returns a unauthorized response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT #update' do
        let(:employee) { create(:employee) }
        let(:company_employee) { create(:company_employee, employee:, company:) }

        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            context 'when companies_params is not send' do
              let(:user) { create(:tenant_user) }
              let(:employee_params) { { name: 'new_name' } }

              before do
                put "/api/v1/employees/#{employee.id}", params: { employee: employee_params }, headers: { 'Authorization': "Bearer #{token}" }
              end

              it 'updates a new employee' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(employee_params[:name])
                employee.reload
                expect(employee.name).to eq('new_name')
              end
            end

            context 'when companies_params is send' do
              let(:user) { create(:tenant_user) }
              let(:employee_params) { { name: 'new_name' } }
              let(:companies_params) { [ { id: company.id, tenant_id: user.profile_id } ] }

              before do
                expect(CompanyEmployee).to receive(:create!).with(company_id: company.id.to_s, employee_id: employee.id)

                put "/api/v1/employees/#{employee.id}", params: { employee: employee_params, companies: companies_params }, headers: { 'Authorization': "Bearer #{token}" }
              end

              it 'updates a new employee' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(employee_params[:name])
                employee.reload
                expect(employee.name).to eq('new_name')
              end
            end
          end

          context 'when user is a employee' do
            context 'when employee updated is logged' do
              let(:user) { create(:employee_user) }
              let(:employee_params) { { name: 'new_name' } }

              before do
                put "/api/v1/employees/#{user.profile.id}", params: { employee: employee_params }, headers: { 'Authorization': "Bearer #{token}" }
              end

              it 'updates a new employee' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(employee_params[:name])
                user.profile.reload
                expect(user.profile.name).to eq('new_name')
              end
            end

            context 'when employee logged try to updated another employee' do
              let(:user) { create(:employee_user) }
              let(:employee_params) { { name: 'new_name' } }

              it 'returns a forbidden response' do
                put "/api/v1/employees/#{employee.id}", headers: { 'Authorization': "Bearer #{token}" }

                expect(response).to have_http_status(:forbidden)
              end
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              put "/api/v1/employees/#{employee.id}", headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/employees/#{employee.id}"
          end

          it "returns a unauthorized response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
