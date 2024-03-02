# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'CompanyEmailTemplateController', type: :request do
      let(:token) { Concerns::JwtToken.generate_token(user, company.id) }
      let(:company) { create(:company) }

      let(:company_email_template) do
        create(:company_email_template, subject: 'any_subject', body: 'any_body', email_template: create(:user_register_email_template_action), company:)
      end

      describe 'GET #index' do
        context 'when user is logged in' do
          context 'when company email template is found' do
            before do
              create(:system_configuration)
            end

            context 'when user is a tenant' do
              let(:user) { create(:tenant_user) }

              context 'when company email template belongs to logged company' do
                before do
                  create(:company_email_template, subject: 'any_subject', body: 'any_body', email_template: create(:user_register_email_template_action), company:)

                  get "/api/v1/company_email_templates", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(company_email_template.subject)
                  expect(response.body).to include(company_email_template.body)
                end
              end

              context 'when company email template cannot belongs to logged company' do
                before do
                  create(:company_email_template, email_template: create(:user_register_email_template_action))

                  get "/api/v1/company_email_templates", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(JSON.parse(response.body)).to eq([])
                end
              end
            end

            context 'when user is a employee' do
              let(:user) { create(:employee_user) }

              context 'when company email template belongs to logged company' do
                before do
                  create(:company_employee, employee: user.profile, company:)
                  create(:company_email_template, subject: 'any_subject', body: 'any_body', email_template: create(:user_register_email_template_action), company:)

                  get "/api/v1/company_email_templates", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(company_email_template.subject)
                  expect(response.body).to include(company_email_template.body)
                end
              end

              context 'when company email template cannot belongs to logged company' do
                
                before do
                  create(:company_email_template, email_template: create(:user_register_email_template_action))

                  get "/api/v1/company_email_templates", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(JSON.parse(response.body)).to eq([])
                end
              end
            end

            context 'when user is an admin' do
              let(:user) { create(:user) }

              it 'returns a forbidden response' do
                get "/api/v1/company_email_templates", headers: { 'Authorization': "Bearer #{token}" }

                expect(response).to have_http_status(:forbidden)
              end
            end
          end

          context 'when company email template is not found' do
            before do
              get "/api/v1/company_email_templates"
            end

            it "returns a success response" do
              expect(response).to have_http_status(:unauthorized)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            get "/api/v1/company_email_templates"
          end

          it "returns a success response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'GET #show' do
        context 'when user is logged in' do
          context 'when company email template is found' do
            before do
              create(:system_configuration)
            end

            context 'when user is a tenant' do
              let(:user) { create(:tenant_user) }

              context 'when company email template belongs to logged company' do
                before do
                  get "/api/v1/company_email_templates/#{company_email_template.id}", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(company_email_template.subject)
                  expect(response.body).to include(company_email_template.body)
                end
              end

              context 'when company email template cannot belongs to logged company' do
                let(:company_email_template) { create(:company_email_template, email_template: create(:user_register_email_template_action)) }

                before do
                  get "/api/v1/company_email_templates/#{company_email_template.id}", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(response).to have_http_status(:not_found)
                end
              end
            end

            context 'when user is a employee' do
              let(:user) { create(:employee_user) }

              context 'when company email template belongs to logged company' do
                before do
                  get "/api/v1/company_email_templates/#{company_email_template.id}", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(company_email_template.subject)
                  expect(response.body).to include(company_email_template.body)
                end
              end

              context 'when company email template cannot belongs to logged company' do
                let(:company_email_template) { create(:company_email_template, email_template: create(:user_register_email_template_action)) }

                before do
                  get "/api/v1/company_email_templates/#{company_email_template.id}", headers: { 'Authorization': "Bearer #{token}" }
                end

                it 'show a company email template' do
                  expect(response).to have_http_status(:not_found)
                end
              end
            end

            context 'when user is an admin' do
              let(:user) { create(:user) }

              it 'returns a forbidden response' do
                get "/api/v1/company_email_templates/#{company_email_template.id}", headers: { 'Authorization': "Bearer #{token}" }

                expect(response).to have_http_status(:forbidden)
              end
            end
          end

          context 'when company email template is not found' do
            before do
              get "/api/v1/company_email_templates/any_invalid_id"
            end
      
            it "returns a success response" do
              expect(response).to have_http_status(:unauthorized)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            get "/api/v1/company_email_templates/#{company_email_template.id}"
          end

          it "returns a success response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT #update' do
        context 'when user is logged in' do
          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }
            let(:company_email_template_params) { { subject: 'new_subject', body: 'new_body' } }

            before do
              create(:system_configuration)

              put "/api/v1/company_email_templates/#{company_email_template.id}", params: { company_email_template: company_email_template_params}, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'updates a new company_email_template' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(company_email_template_params[:subject])
              expect(response.body).to include(company_email_template_params[:body])
              company_email_template.reload
              expect(company_email_template.subject).to eq('new_subject')
              expect(company_email_template.body).to eq('new_body')
            end
          end

          context 'when user is a tenant' do
            let(:user) { create(:employee_user) }
            let(:company_email_template_params) { { subject: 'new_subject', body: 'new_body' } }

            before do
              create(:system_configuration)

              put "/api/v1/company_email_templates/#{company_email_template.id}", params: { company_email_template: company_email_template_params}, headers: { 'Authorization': "Bearer #{token}" }
            end

            it 'updates a new company_email_template' do
              expect(response).to have_http_status(:ok)
              expect(response.body).to include(company_email_template_params[:subject])
              expect(response.body).to include(company_email_template_params[:body])
              company_email_template.reload
              expect(company_email_template.subject).to eq('new_subject')
              expect(company_email_template.body).to eq('new_body')
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }

            it 'returns a forbidden response' do
              put "/api/v1/company_email_templates/#{company_email_template.id}", headers: { 'Authorization': "Bearer #{token}" }

              expect(response).to have_http_status(:forbidden)
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/company_email_templates/#{company_email_template.id}"
          end

          it "returns a success response" do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
