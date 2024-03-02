# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'ProductsController', type: :request do
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
              create_list(:product, 1)

              get '/api/v1/products', headers: { 'Authorization': "Bearer #{token}" }
            end

            it "returns a forbidden response" do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:product_type) { create(:product_type, company:) }

            before do
              create_list(:product, 3)
              create_list(:product, 5, product_type:)

              get '/api/v1/products', headers: { 'Authorization': "Bearer #{token}" }
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
            let(:product_type) { create(:product_type, company:) }

            before do
              create_list(:product, 3)
              create_list(:product, 4, product_type:)

              get '/api/v1/products', headers: { 'Authorization': "Bearer #{token}" }
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
            get '/api/v1/products'
          end

          it "returns a unauthorized response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'POST #create' do
        context 'when user is logged in' do
          let(:product_type) { create(:product_type) }

          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:product_params) { attributes_for(:product) }

            before do
              post '/api/v1/products', params: { product: product_params.merge(product_type_id: product_type.id) }, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'creates a new product' do
              expect(response).to have_http_status(:ok)
              product = Product.last
              expect(product.name).to eq(product_params[:name])
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }
            let(:product_params) { attributes_for(:product) }

            before do
              post '/api/v1/products', params: { product: product_params.merge(product_type_id: product_type.id) }, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'creates a new product' do
              expect(response).to have_http_status(:ok)
              product = Product.last
              expect(product.name).to eq(product_params[:name])
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              post '/api/v1/products', headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            post '/api/v1/products'
          end

          it "returns a unauthorized response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT #update' do
        let(:product_type) { create(:product_type, company:)}
        let(:product) { create(:product, product_type:) }

        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:product_params) { { name: 'new_name' } }

            before do
              put "/api/v1/products/#{product.id}", params: { product: product_params }, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'updates a new product' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(product_params[:name])
              product.reload
              expect(product.name).to eq('new_name')
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }
            let(:product_params) { { name: 'new_name' } }

            before do
              put "/api/v1/products/#{product.id}", params: { product: product_params }, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'updates a new product' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(product_params[:name])
              product.reload
              expect(product.name).to eq('new_name')
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              put "/api/v1/products/#{product.id}", headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/products/#{product.id}"
          end

          it "returns a unauthorized response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
