# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'CompaniesController', type: :request do
      let(:token) { Concerns::JwtToken.generate_token(user) }

      describe 'GET #index' do
        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            before do
              create_list(:company, 3)

              get '/api/v1/companies',
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'returns a forbidden response' do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }

            before do
              create_list(:company, 3)
              create_list(:company, 5, tenant: user.profile)

              get '/api/v1/companies',
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'returns a success response' do
              expect(response).to have_http_status(:success)
            end

            it 'returns JSON response with paginated models' do
              expect(response).to be_successful
              expect(JSON.parse(response.body).size).to eq(5)
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }

            before do
              create_list(:company, 3)
              create_list(:company_employee, 4, employee: user.profile)

              get '/api/v1/companies',
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'returns a success response' do
              expect(response).to have_http_status(:success)
            end

            it 'returns JSON response with paginated models' do
              expect(response).to be_successful
              expect(JSON.parse(response.body).size).to eq(4)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            get '/api/v1/companies'
          end

          it 'returns a unauthorized response' do
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
            let(:company_params) { attributes_for(:company) }
            let(:address_params) { attributes_for(:address) }

            before do
              post '/api/v1/companies',
                   params: {
                     company: company_params,
                     address: address_params
                   }, headers: { Authorization: "Bearer #{token}" }
            end

            it 'creates a new company' do
              expect(response).to have_http_status(:ok)
              company = Company.last
              expect(company.name).to eq(company_params[:name])
              expect(company.address.street).to eq(address_params[:street])
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }

            it 'returns a forbidden response' do
              post '/api/v1/companies',
                   headers: { Authorization: "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              post '/api/v1/companies',
                   headers: { Authorization: "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            post '/api/v1/companies'
          end

          it 'returns a unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT #update' do
        let(:address) { create(:company_address) }
        let(:company) { address.addressable }

        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:company_params) { { name: 'new_name' } }
            let(:address_params) { { street: 'new street' } }

            before do
              company.tenant = user.profile
              company.save!

              put "/api/v1/companies/#{company.id}",
                  params: {
                    company: company_params, address: address_params
                  },
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'updates a new company' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(company_params[:name])
              company.reload
              expect(company.name).to eq('new_name')
              expect(company.address.street).to eq('new street')
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }
            let(:company_params) { { name: 'new_name' } }
            let(:address_params) { { street: 'new street' } }

            context 'when employee has company association' do
              before do
                create(:company_employee, employee: user.profile, company:)

                put "/api/v1/companies/#{company.id}",
                    params: {
                      company: company_params,
                      address: address_params
                    },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'updates a new company' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(company_params[:name])
                company.reload
                expect(company.name).to eq('new_name')
                expect(company.address.street).to eq('new street')
              end
            end

            context 'when employee has no company association' do
              before do
                put "/api/v1/companies/#{company.id}",
                    params: {
                      company: company_params,
                      address: address_params
                    },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'returns a not_found response' do
                expect(response).to have_http_status(:not_found)
              end
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              put "/api/v1/companies/#{company.id}",
                  headers: { Authorization: "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/companies/#{company.id}"
          end

          it 'returns a unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
