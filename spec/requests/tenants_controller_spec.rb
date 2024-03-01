# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TenantsController', type: :request do
  let(:token) { JwtToken.generate_token(user) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        before do
          create_list(:tenant, 4)

          get '/tenants', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(4)
        end
      end

      context 'when user is an affiliate' do
        let(:user) { create(:affiliate_user) }

        before do
          create_list(:tenant, 4)
          create_list(:tenant, 3, affiliate: user.profile)

          get '/tenants', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(3)
        end
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }

        before do
          create_list(:tenant, 3)

          get '/tenants', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a forbidden response" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        before do
          create_list(:tenant, 3)

          get '/tenants', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a forbidden response" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        get '/tenants'
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

      context 'when user is an affiliate' do
        context 'when a tenant is successfully created' do
          let(:user) { create(:affiliate_user) }
          let(:tenant_params) { attributes_for(:tenant) }
          let(:user_registration_mailer) { double('UserRegistrationMailer') }
          let(:user_data) do 
            { 
              email_address: 'any_email@example.com', password: 'any_password'
            }
          end

          before do
            expect(UserRegistrationMailer).to receive(:send_email).and_return(user_registration_mailer)
            expect(user_registration_mailer).to receive(:deliver_now).and_return(true)

            post '/tenants', params: { tenant: tenant_params, user: user_data }, headers: { 'Authorization': "Bearer #{token}" }
          end

          it 'creates a new tenant' do
            expect(response).to have_http_status(:ok)
            tenant = Tenant.last
            expect(tenant.name).to eq(tenant_params[:name])
            expect(tenant.affiliate_id).to eq(user.profile_id)
          end
        end

        context 'when a tenant is not created successfully' do
          let(:user) { create(:affiliate_user) }
          let(:tenant_params) { attributes_for(:tenant) }
          let(:user_data) do 
            { 
              email_address: 'invalid_email', password: 'any_password'
            }
          end

          before do
            expect(UserRegistrationMailer).to_not receive(:send_email)

            post '/tenants', params: { tenant: tenant_params, user: user_data }, headers: { 'Authorization': "Bearer #{token}" }
          end

          it 'returns a bad request response' do
            post '/tenants', headers: { 'Authorization': "Bearer #{token}" }
  
            expect(response).to have_http_status(:bad_request)
          end
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:tenant_params) { attributes_for(:tenant) }
        let(:user_registration_mailer) { double('UserRegistrationMailer') }
        let(:user_data) do 
          { 
            email_address: 'any_email@example.com', password: 'any_password'
          }
        end

        before do
          expect(UserRegistrationMailer).to receive(:send_email).and_return(user_registration_mailer)
          expect(user_registration_mailer).to receive(:deliver_now).and_return(true)

          post '/tenants', params: { tenant: tenant_params, user: user_data }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'creates a new tenant' do
          expect(response).to have_http_status(:ok)
          tenant = Tenant.last
          expect(tenant.name).to eq(tenant_params[:name])
          expect(tenant.affiliate_id).to be_nil
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          post '/tenants', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }

        it 'returns a forbidden response' do
          post '/tenants', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        post '/tenants'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:tenant) { create(:tenant) }

    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is a tenant' do
        context 'when the tenant updates it' do
          let(:user) { create(:tenant_user) }
          let(:tenant_params) { { name: 'new_name' } }
          let(:tenant) { user.profile }

          before do
            put "/tenants/#{tenant.id}", params: { tenant: tenant_params }, headers: { 'Authorization': "Bearer #{token}" }
          end

          it 'updates a new tenant' do
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(tenant_params[:name])
            tenant.reload
            expect(tenant.name).to eq('new_name')
          end
        end

        context 'when tenant tries to update another tenant' do
          let(:user) { create(:tenant_user) }
          let(:tenant_params) { { name: 'new_name' } }

          it 'returns a forbidden response' do
            put "/tenants/#{tenant.id}", headers: { 'Authorization': "Bearer #{token}" }
  
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          put "/tenants/#{tenant.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an affiliate' do
        let(:user) { create(:affiliate_user) }

        it 'returns a forbidden response' do
          put "/tenants/#{tenant.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:tenant_params) { { name: 'new_name' } }

        before do
          put "/tenants/#{tenant.id}", params: { tenant: tenant_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new tenant' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(tenant_params[:name])
          tenant.reload
          expect(tenant.name).to eq('new_name')
        end
      end
    end

    context 'when user is not logger in' do
      before do
        put "/tenants/#{tenant.id}"
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
