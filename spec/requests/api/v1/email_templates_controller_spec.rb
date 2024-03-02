# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'EmailTemplateController', type: :request do
      let(:token) { Concerns::JwtToken.generate_token(user) }

      let(:email_template) do
        create(:user_register_email_template_action, subject: 'any_subject', body: 'any_body')
      end

      describe 'GET #index' do
        context 'when user is logged in' do
          before do
            create(:system_configuration)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }

            before do
              get "/api/v1/email_templates", headers: { 'Authorization': "Bearer #{token}" }
            end

            it "returns a forbidden response" do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }

            before do
              get "/api/v1/email_templates", headers: { 'Authorization': "Bearer #{token}" }
            end

            it "returns a forbidden response" do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            before do
              create(:user_register_email_template_action, subject: 'any_subject', body: 'any_body')

              get "/api/v1/email_templates", headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'show a email template' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include('any_subject')
              expect(response.body).to include('any_body')
            end
          end
        end

        context 'when user is not logger in' do
          before do
            get "/api/v1/email_templates"
          end

          it "returns a success response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'GET #show' do
        context 'when user is logged in' do
          context 'when email template is found' do
            before do
              create(:system_configuration)

              get "/api/v1/email_templates/#{email_template.id}", headers: { 'Authorization': "Bearer #{token}" }
            end

            context 'when user is a tenant' do
              let(:user) { create(:tenant_user) }

              it 'show a email template' do
                expect(response).to have_http_status(:forbidden)
              end
            end

            context 'when user is a employee' do
              let(:user) { create(:employee_user) }

              it 'show a email template' do
                expect(response).to have_http_status(:forbidden)
              end
            end

            context 'when user is an admin' do
              let(:user) { create(:user) }

              it 'returns a email template' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(email_template.subject)
                expect(response.body).to include(email_template.body)
              end
            end
          end

          context 'when email template is not found' do
            before do
              get "/api/v1/email_templates/any_invalid_id"
            end
      
            it "returns a success response" do
              expect(response).to have_http_status(:unauthorized)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            get "/api/v1/email_templates/#{email_template.id}"
          end

          it "returns a success response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT #update' do
        context 'when user is logged in' do
          context 'when user is an admin' do
            let(:user) { create(:user) }
            let(:email_template_params) { { subject: 'new_subject', body: 'new_body' } }

            before do
              create(:system_configuration)

              put "/api/v1/email_templates/#{email_template.id}", params: { email_template: email_template_params}, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'updates a new email_template' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(email_template_params[:subject])
              expect(response.body).to include(email_template_params[:body])
              email_template.reload
              expect(email_template.subject).to eq('new_subject')
              expect(email_template.body).to eq('new_body')
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }

            before do
              create(:system_configuration)
            end

            it 'returns a forbidden response' do
              put "/api/v1/email_templates/#{email_template.id}", headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }

            before do
              create(:system_configuration)
            end

            it 'returns a forbidden response' do
              put "/api/v1/email_templates/#{email_template.id}", headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/email_templates/#{email_template.id}"
          end

          it "returns a success response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
