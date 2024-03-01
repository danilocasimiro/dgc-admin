# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SubscriptionsController', type: :request do
  let(:token) { JwtToken.generate_token(user) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        before do
          create_list(:subscription, 5)

          get '/subscriptions', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(5)
        end
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }

        before do
          create_list(:subscription, 1, tenant: user.profile)
          create_list(:subscription, 3)

          get '/subscriptions', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(1)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        before do
          create_list(:subscription, 1)

          get '/subscriptions', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a unauthorized response" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        get '/subscriptions'
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
        let(:subscription_params) { attributes_for(:subscription) }
        let(:subscription_plan) { create(:subscription_plan) }

        before do
          post '/subscriptions', params: { subscription: subscription_params.merge(subscription_plan_id: subscription_plan.id) }, headers: { 'Authorization': "Bearer #{token}" }        
        end

        it 'creates a new subscription' do
          expect(response).to have_http_status(:ok)
          subscription = Subscription.last
          expect(subscription.subscription_plan_id).to eq(subscription_plan.id)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          post '/subscriptions', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        it 'returns a forbidden response' do
          post '/subscriptions', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        post '/subscriptions'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:subscription) { create(:subscription) }

    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }
        let(:subscription) { create(:subscription, tenant: user.profile) }
        let(:subscription_params) { { status: 'inactive' } }

        before do
          put "/subscriptions/#{subscription.id}", params: { subscription: subscription_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new subscription' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(subscription_params[:status])
          subscription.reload
          expect(subscription.status).to eq('inactive')
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          put "/subscriptions/#{subscription.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        it 'returns a forbidden response' do
          put "/subscriptions/#{subscription.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        put "/subscriptions/#{subscription.id}"
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
