# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AffiliatesController', type: :request do
  let(:token) { JwtToken.generate_token(user) }

  describe 'GET #index' do
    context 'when user is logged in' do
      context 'when user is an admin' do
        let(:user) { create(:user) }

        before do
          create_list(:affiliate, 3)

          get '/affiliates', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(3)
        end
      end

      context 'when user is not an admin' do
        let(:user) { create(:affiliate_user) }

        it 'returns a forbidden response' do
          get '/affiliates', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        get '/affiliates'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is logged in' do
      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:affiliate_params) { attributes_for(:affiliate) }
        let(:user_registration_mailer) { double('UserRegistrationMailer') }
        let(:user_data) do 
          { 
            email_address: 'any_email@example.com', password: 'any_password'
          }
        end

        before do
          expect(UserRegistrationMailer).to receive(:send_email).and_return(user_registration_mailer)
          expect(user_registration_mailer).to receive(:deliver_now).and_return(true)

          post '/affiliates', params: { affiliate: affiliate_params, user: user_data}, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'creates a new affiliate' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(affiliate_params[:name])
        end
      end

      context 'when user is not an admin' do
        let(:user) { create(:affiliate_user) }

        it 'returns a forbidden response' do
          post '/affiliates', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        post '/affiliates'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:affiliate) { create(:affiliate, name: 'any_name') }

    context 'when user is logged in' do
      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:affiliate_params) { { name: 'new_name' } }
        let(:user_data) { { email_address: 'new_email@example.com' } }

        before do
          put "/affiliates/#{affiliate.id}", params: { affiliate: affiliate_params, user: user_data}, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new affiliate' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(affiliate_params[:name])
          affiliate.reload
          expect(affiliate.name).to eq('new_name')
          expect(affiliate.user.email_address).to eq('new_email@example.com')
        end
      end

      context 'when user is not an admin' do
        let(:user) { create(:client_user) }

        it 'returns a forbidden response' do
          put "/affiliates/#{affiliate.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        put "/affiliates/#{affiliate.id}"
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
