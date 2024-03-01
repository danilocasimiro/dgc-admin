# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SystemConfigurationsController', type: :request do
  let(:token) { JwtToken.generate_token(user) }

  describe 'PUT #update' do
    let(:system_configuration) { create(:system_configuration) }

    context 'when user is logged in' do
      context 'when user is a tenant' do
        let(:user) { create(:tenant_user) }

        it 'returns a forbidden response' do
          put "/system_configurations/#{system_configuration.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is a employee' do
        let(:user) { create(:employee_user) }

        it 'returns a forbidden response' do
          put "/system_configurations/#{system_configuration.id}", headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user) }
        let(:system_configuration_params) { { maintenance_mode: true } }

        before do
          put "/system_configurations/#{system_configuration.id}", params: { system_configuration: system_configuration_params }, headers: { 'Authorization': "Bearer #{token}" }
        end

        it 'updates a new system_configuration' do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(system_configuration_params[:maintenance_mode].to_s)
          system_configuration.reload
          expect(system_configuration.maintenance_mode).to eq(true)
        end
      end
    end

    context 'when user is not logger in' do
      before do
        put "/system_configurations/#{system_configuration.id}"
      end

      it "returns a unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      context 'when system configuration is found' do
        let(:system_configuration) { create(:system_configuration) }

        context 'when user is a tenant' do
          let(:user) { create(:tenant_user) }

          before do
            get "/system_configurations/#{system_configuration.id}", headers: { 'Authorization': "Bearer #{token}" }
          end

          it 'show a system configuration' do
            expect(response).to have_http_status(:forbidden)
          end
        end

        context 'when user is a employee' do
          let(:user) { create(:employee_user) }

          before do
            get "/system_configurations/#{system_configuration.id}", headers: { 'Authorization': "Bearer #{token}" }
          end

          it 'show a system configuration' do
            expect(response).to have_http_status(:forbidden)
          end
        end

        context 'when user is an admin' do
          let(:user) { create(:user) }

          before do
            get "/system_configurations/#{system_configuration.id}", headers: { 'Authorization': "Bearer #{token}" }
          end

          it 'show a system configuration' do
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(system_configuration.maintenance_mode.to_s)
            expect(response.body).to include(system_configuration.grace_period_days.to_s)
          end
        end
      end

      context 'when system configuration is not found' do
        let(:user) { create(:user) }

        before do
          get "/system_configurations/any_invalid_id", headers: { 'Authorization': "Bearer #{token}" }
        end

        it "returns a success response" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not logger in' do
      let(:system_configuration) { create(:system_configuration) }

      before do
        get "/system_configurations/#{system_configuration.id}"
      end

      it "returns a success response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
