# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AuthenticationController', type: :request do
  describe 'POST #authenticate' do
    context 'when user is find' do
      let(:user) { create(:user, status:, password:) }
      let(:password) { '123456' }
      let(:email_address) { user.email_address }
      let(:token) { 'any_token' }

      context 'when user is active' do
        let(:status) { 'active' }

        before do
          expect(JwtToken).to receive(:generate_token).with(user).and_return(token)
          post '/authenticate', params: {  email_address:, password: }
        end

        it 'generates a new token' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(token)
        end
      end

      context 'when user is inactive' do
        let(:status) { 'inactive' }
        let(:user_registration_mailer) { double('UserRegistrationMailer') }

        before do
          expect(UserRegistrationMailer).to receive(:send_email).and_return(user_registration_mailer)
          expect(user_registration_mailer).to receive(:deliver_now).and_return(true)

          post '/authenticate', params: {  email_address:, password:}
        end

        it "returns a unauthorized response" do
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to include("Usuário inativo. Um novo email foi encaminhado para #{user.email_address} para realizar a ativação de sua conta.")
        end
      end
    end

    context 'when user is not found' do
      let(:password) { '123456' }
      let(:email_address) { 'email@example.com' }

      before do
        post '/authenticate', params: {  email_address:, password:}
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Credenciais inválidas.")
      end
    end
  end

  describe 'POST #logout_company_auth' do
    before do
      post '/authenticate/logout_company_auth', headers: { 'Authorization': "Bearer #{token}" }
    end

    context 'when token is valid' do
      let(:token) { JwtToken.generate_token(user) }
      let(:user) { create(:user) }

      it 'generates a new token' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(token)
      end
    end

    context 'when token is invalid' do
      let(:token) { 'any_invalid_token' }

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Necessário autenticação")
      end
    end
  end

  describe 'POST #company_auth' do
    let(:token) { JwtToken.generate_token(user) }

    context 'when user is logged in' do
      let(:user) { create(:tenant_user) }

      before do
        create(:system_configuration)
      end

      context 'when company belongs to the logged user' do
        let(:company) { create(:company, tenant: user.profile) }

        before do
          post "/authenticate/company_auth/#{company.id}", headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'generates a new token' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the company does not belong to the logged in user' do
        let(:company) { create(:company) }

        before do
          post "/authenticate/company_auth/#{company.id}", headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a not found response" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        post '/authenticate/company_auth/123'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end