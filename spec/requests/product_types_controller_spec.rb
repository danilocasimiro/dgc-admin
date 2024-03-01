# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ProductTypesController', type: :request do
  let(:token) { JwtToken.generate_token(user, company.id) }
  let(:company) { create(:company) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        before do
          create_list(:product_type, 1)

          get '/product_types', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a forbidden response" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }

        before do
          create_list(:product_type, 3)
          create_list(:product_type, 5, company:)

          get '/product_types', headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "returns JSON response with paginated models" do
          expect(response).to be_successful
          expect(JSON.parse(response.body).size).to eq(5)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        before do
          create_list(:product_type, 3)
          create_list(:product_type, 4, company:)

          get '/product_types', headers: { 'Authorization': "Bearer #{token}" }
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

    context 'when user is not logger in' do
      before do
        get '/product_types'
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
        let(:product_type_params) { attributes_for(:product_type) }

        before do
          post '/product_types', params: { product_type: product_type_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'creates a new product_type' do
          expect(response).to have_http_status(:ok)
          product_type = ProductType.last
          expect(product_type.name).to eq(product_type_params[:name])
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }
        let(:product_type_params) { attributes_for(:product_type) }

        before do
          post '/product_types', params: { product_type: product_type_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'creates a new product_type' do
          expect(response).to have_http_status(:ok)
          product_type = ProductType.last
          expect(product_type.name).to eq(product_type_params[:name])
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        it 'returns a forbidden response' do
          post '/product_types', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        post '/product_types'
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:product_type) { create(:product_type, company:) }

    context 'when user is logged in' do
      before do
        create(:system_configuration)
      end

      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }
        let(:product_type_params) { { name: 'new_name' } }

        before do
          put "/product_types/#{product_type.id}", params: { product_type: product_type_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new product_type' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(product_type_params[:name])
          product_type.reload
          expect(product_type.name).to eq('new_name')
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }
        let(:product_type_params) { { name: 'new_name' } }

        before do
          put "/product_types/#{product_type.id}", params: { product_type: product_type_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new product_type' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(product_type_params[:name])
          product_type.reload
          expect(product_type.name).to eq('new_name')
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }

        it 'returns a forbidden response' do
          put "/product_types/#{product_type.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        put "/product_types/#{product_type.id}"
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
