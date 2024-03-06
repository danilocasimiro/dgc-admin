# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'ClientsController', type: :request do
      let(:token) { Concerns::JwtToken.generate_token(user, company.id) }
      let(:company) { create(:company) }

      describe 'GET #index' do
        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            before do
              create_list(:client, 3)

              get '/api/v1/clients',
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'returns a forbidden response' do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }

            before do
              create_list(:client, 3)
              create_list(:company_client, 5, company:)

              get '/api/v1/clients',
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
              create_list(:client, 3)
              create_list(:company_client, 5, company:)

              get '/api/v1/clients',
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
        end

        context 'when user is not logger in' do
          before do
            get '/api/v1/clients'
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
            let(:client_params) { attributes_for(:client) }
            let(:address_params) { attributes_for(:address) }
            let(:user_registration_mailer) { double('UserRegistrationMailer') }
            let(:user_data) do
              {
                email_address: 'any_email@example.com', password: 'any_password'
              }
            end

            before do
              expect(UserRegistrationMailer).to receive(:send_email)
                .and_return(user_registration_mailer)
              expect(user_registration_mailer).to receive(:deliver_now)
                .and_return(true)

              post '/api/v1/clients',
                   params: {
                     client: client_params,
                     address: address_params,
                     user: user_data
                   },
                   headers: { Authorization: "Bearer #{token}" }
            end

            it 'creates a new client' do
              expect(response).to have_http_status(:ok)
              client = Client.last
              expect(client.name).to eq(client_params[:name])
              expect(client.user.email_address).to eq(user_data[:email_address])
              expect(client.address.street).to eq(address_params[:street])
              expect(client.companies.find(company.id)).to eq(company)
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }
            let(:client_params) { attributes_for(:client) }
            let(:address_params) { attributes_for(:address) }
            let(:user_registration_mailer) { double('UserRegistrationMailer') }
            let(:user_data) do
              {
                email_address: 'any_email@example.com', password: 'any_password'
              }
            end

            before do
              expect(UserRegistrationMailer).to receive(:send_email)
                .and_return(user_registration_mailer)
              expect(user_registration_mailer).to receive(:deliver_now)
                .and_return(true)

              post '/api/v1/clients',
                   params: {
                     client: client_params,
                     address: address_params,
                     user: user_data
                   },
                   headers: { Authorization: "Bearer #{token}" }
            end

            it 'creates a new client' do
              expect(response).to have_http_status(:ok)
              client = Client.last
              expect(client.name).to eq(client_params[:name])
              expect(client.user.email_address).to eq(user_data[:email_address])
              expect(client.address.street).to eq(address_params[:street])
              expect(client.companies.find(company.id)).to eq(company)
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              post '/api/v1/clients',
                   headers: { Authorization: "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            post '/api/v1/clients'
          end

          it 'returns a unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT #update' do
        let(:company_client) { create(:company_client, company:) }
        let(:client) { company_client.client }

        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:client_params) { { name: 'new_name' } }
            let(:address_params) { { street: 'new street' } }
            let(:user_data) { { email_address: 'any_email@example.com' } }

            before do
              put "/api/v1/clients/#{client.id}",
                  params: {
                    client: client_params,
                    address: address_params,
                    user: user_data
                  },
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'updates a new client' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(client_params[:name])
              client.reload
              expect(client.name).to eq('new_name')
              expect(client.address.street).to eq('new street')
              expect(client.user.email_address).to eq('any_email@example.com')
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }
            let(:client_params) { { name: 'new_name' } }
            let(:address_params) { { street: 'new street' } }
            let(:user_data) { { email_address: 'any_email@example.com' } }

            before do
              put "/api/v1/clients/#{client.id}",
                  params: {
                    client: client_params,
                    address: address_params,
                    user: user_data
                  },
                  headers: { Authorization: "Bearer #{token}" }
            end

            it 'updates a new client' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(client_params[:name])
              client.reload
              expect(client.name).to eq('new_name')
              expect(client.address.street).to eq('new street')
              expect(client.user.email_address).to eq('any_email@example.com')
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              put "/api/v1/clients/#{client.id}",
                  headers: { Authorization: "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/clients/#{client.id}"
          end

          it 'returns a unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
