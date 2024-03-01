# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SubscriptionPlansController', type: :request do
  let(:token) { JwtToken.generate_token(user) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        before do
          create_list(:subscription_plan, 5)

          get '/subscription_plans', headers: { 'Authorization': "Bearer #{token}" }
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
          create_list(:subscription_plan, 1)

          get '/subscription_plans', headers: { 'Authorization': "Bearer #{token}" }
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
          create_list(:subscription_plan, 1)

          get '/subscription_plans', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(1)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        get '/subscription_plans'
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

        it 'returns a forbidden response' do
          post '/subscription_plans', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          post '/subscription_plans', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:subscription_plan_params) { attributes_for(:subscription_plan) }

        before do
          post '/subscription_plans', params: { subscription_plan: subscription_plan_params }, headers: { 'Authorization': "Bearer #{token}" }        
        end

        it 'creates a new subscription_plan' do
          expect(response).to have_http_status(:ok)
          subscription_plan = SubscriptionPlan.last
          expect(subscription_plan.name).to eq(subscription_plan_params[:name])
        end
      end
    end

    context 'when user is not logger in' do
      before do
        post '/subscription_plans'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:subscription_plan) { create(:subscription_plan) }

    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }

        it 'returns a forbidden response' do
          put "/subscription_plans/#{subscription_plan.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          put "/subscription_plans/#{subscription_plan.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:subscription_plan_params) { { name: 'new_name' } }

        before do
          put "/subscription_plans/#{subscription_plan.id}", params: { subscription_plan: subscription_plan_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new subscription_plan' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(subscription_plan_params[:name])
          subscription_plan.reload
          expect(subscription_plan.name).to eq('new_name')
        end

      end
    end

    context 'when user is not logger in' do
      before do
        put "/subscription_plans/#{subscription_plan.id}"
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
