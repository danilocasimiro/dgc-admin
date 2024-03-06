# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe 'UsersController', type: :request do
      let(:token) { Concerns::JwtToken.generate_token(user) }

      before do
        create(:system_configuration)
      end

      describe 'PUT #update' do
        let(:user) { create(:user) }

        context 'when user is logged in' do
          before do
            create(:user)
          end

          context 'when user is a tenant' do
            let(:user) { create(:tenant_user) }

            context 'when the user updates it' do
              let(:user_params) { { email_address: 'new_email@example.com' } }

              before do
                put "/api/v1/users/#{user.id}",
                    params: { user: user_params },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'updates a new user' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(user_params[:email_address])
                user.reload
                expect(user.email_address).to eq('new_email@example.com')
              end
            end

            context 'when tenant tries to update another user' do
              let(:another_user) { create(:user) }

              it 'returns a forbidden response' do
                put "/api/v1/users/#{another_user.id}",
                    headers: { Authorization: "Bearer #{token}" }

                expect(response).to have_http_status(:forbidden)
              end
            end
          end

          context 'when user is a employee' do
            let(:user) { create(:employee_user) }

            context 'when the user updates it' do
              let(:user_params) { { email_address: 'new_email@example.com' } }

              before do
                put "/api/v1/users/#{user.id}",
                    params: { user: user_params },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'updates a new user' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(user_params[:email_address])
                user.reload
                expect(user.email_address).to eq('new_email@example.com')
              end
            end

            context 'when tenant tries to update another user' do
              let(:another_user) { create(:user) }

              it 'returns a forbidden response' do
                put "/api/v1/users/#{another_user.id}",
                    headers: { Authorization: "Bearer #{token}" }

                expect(response).to have_http_status(:forbidden)
              end
            end
          end

          context 'when user is an affiliate' do
            let(:user) { create(:affiliate_user) }

            context 'when the user updates it' do
              let(:user_params) { { email_address: 'new_email@example.com' } }

              before do
                put "/api/v1/users/#{user.id}",
                    params: { user: user_params },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'updates a new user' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(user_params[:email_address])
                user.reload
                expect(user.email_address).to eq('new_email@example.com')
              end
            end

            context 'when tenant tries to update another user' do
              let(:another_user) { create(:user) }

              it 'returns a forbidden response' do
                put "/api/v1/users/#{another_user.id}",
                    headers: { Authorization: "Bearer #{token}" }

                expect(response).to have_http_status(:forbidden)
              end
            end
          end

          context 'when user is an admin' do
            let(:user) { create(:user) }
            let(:user_params) { { email_address: 'new_email@example.com' } }

            context 'when the user updates it' do
              before do
                put "/api/v1/users/#{user.id}",
                    params: { user: user_params },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'updates a new user' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(user_params[:email_address])
                user.reload
                expect(user.email_address).to eq('new_email@example.com')
              end
            end

            context 'when tenant tries to update another user' do
              let(:update_user) { create(:tenant_user) }

              before do
                put "/api/v1/users/#{update_user.id}",
                    params: { user: user_params },
                    headers: { Authorization: "Bearer #{token}" }
              end

              it 'updates a new user' do
                expect(response).to have_http_status(:ok)
                expect(response.body).to include(user_params[:email_address])
                update_user.reload
                expect(update_user.email_address).to eq('new_email@example.com')
              end
            end
          end
        end

        context 'when user is not logger in' do
          before do
            put "/api/v1/users/#{user.id}"
          end

          it 'returns a unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'GET #show' do
        context 'when user is logged in' do
          context 'when user logged is admin' do
            let(:user) { create(:user) }

            context 'when user is found' do
              context 'when the user sought is the logged in user' do
                before do
                  get "/api/v1/users/#{user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns an user' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(user.email_address)
                end
              end

              context 'when the user sought is a tenant' do
                let(:tenant_user) { create(:tenant_user) }

                before do
                  get "/api/v1/users/#{tenant_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns an user' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(tenant_user.email_address)
                end
              end

              context 'when the user sought is a affiliate' do
                let(:affiliate) { create(:affiliate, user: create(:user)) }

                before do
                  get "/api/v1/users/#{affiliate.user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns an user' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(affiliate.user.email_address)
                end
              end

              context 'when the user sought is a employee' do
                let(:employee_user) { create(:employee_user) }

                before do
                  get "/api/v1/users/#{employee_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns an user' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(employee_user.email_address)
                end
              end

              context 'when the user sought is a client' do
                let(:client_user) { create(:client_user) }

                before do
                  get "/api/v1/users/#{client_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns an user' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(client_user.profile.name)
                end
              end
            end

            context 'when user is not found' do
              before do
                get '/api/v1/users/any_invalid_id'
              end

              it 'returns a not found response' do
                expect(response).to have_http_status(:not_found)
              end
            end
          end

          context 'when user logged is tenant' do
            let(:user) { create(:tenant_user) }

            context 'when user is found' do
              context 'when the user sought is the logged in user' do
                before do
                  get "/api/v1/users/#{user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns an user' do
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to include(user.email_address)
                end
              end

              context 'when the user sought is a tenant' do
                let(:tenant_user) { create(:tenant_user) }

                before do
                  get "/api/v1/users/#{tenant_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns a forbidden response' do
                  expect(response).to have_http_status(:forbidden)
                end
              end

              context 'when the user sought is a affiliate' do
                let(:affiliate_user) { create(:affiliate_user) }

                before do
                  get "/api/v1/users/#{affiliate_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns a forbidden response' do
                  expect(response).to have_http_status(:forbidden)
                end
              end

              context 'when the user sought is a employee' do
                let(:employee_user) { create(:employee_user) }

                before do
                  get "/api/v1/users/#{employee_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns a forbidden response' do
                  expect(response).to have_http_status(:forbidden)
                end
              end

              context 'when the user sought is a client' do
                let(:client_user) { create(:client_user) }

                before do
                  get "/api/v1/users/#{client_user.id}",
                      headers: { Authorization: "Bearer #{token}" }
                end

                it 'returns a forbidden response' do
                  expect(response).to have_http_status(:forbidden)
                end
              end
            end

            context 'when user is not found' do
              before do
                get '/api/v1/users/any_invalid_id'
              end

              it 'returns a not found response' do
                expect(response).to have_http_status(:not_found)
              end
            end
          end
        end

        context 'when user is not logger in' do
          let(:unlogged_user) { create(:user) }

          before do
            get "/api/v1/users/#{unlogged_user.id}"
          end

          it 'returns a success response' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe 'PUT activate' do
        context 'when user activation is successful' do
          let(:user) { create(:user) }
          let(:token) { SecureRandom.hex(20) }
          let(:validation_type) { 'registration' }
          let(:inactive_user) { create(:user, status: :inactive) }
          let(:activate_params) { { token:, validation_type: } }

          before do
            create(:validation, token:, user_id: inactive_user.id,
                                validation_type:)

            put "/api/v1/users/#{inactive_user.id}/activate",
                params: activate_params
          end

          it 'updates user status to active' do
            expect(response).to have_http_status(:ok)
            inactive_user.reload
            expect(inactive_user.status).to eq('active')
            expect(inactive_user.validations.last.status).to eq('used')
          end
        end

        context 'when user activation is unsuccessful' do
          context 'when validation is not found' do
            let(:user) { create(:user) }
            let(:token) { SecureRandom.hex(20) }
            let(:validation_type) { 'registration' }
            let(:inactive_user) { create(:user, status: :inactive) }
            let(:activate_params) { { token:, validation_type: } }

            before do
              put "/api/v1/users/#{inactive_user.id}/activate",
                  params: activate_params
            end

            it 'returns a not found response' do
              expect(response).to have_http_status(:not_found)
            end
          end
        end
      end

      describe 'POST password_recovery' do
        context 'when user is found' do
          let(:user) { create(:user) }
          let(:password_recovery_params) do
            { email_address: user.email_address }
          end
          let(:user_password_recovery_mailer) do
            double('UserPasswordRecoveryMailer')
          end

          before do
            expect(UserPasswordRecoveryMailer).to receive(:send_email)
              .and_return(user_password_recovery_mailer)
            expect(user_password_recovery_mailer).to receive(:deliver_now)
              .and_return(true)
          end

          context 'when validation is found' do
            before do
              create(:validation, user:, validation_type: 1, status: 0)

              post '/api/v1/users/password_recovery',
                   params: password_recovery_params
            end

            it 'sends password recovery email to user' do
              expect(response).to have_http_status(:ok)
              user.reload
              expect(user.validations.first.status).to eq('canceled')
              expect(user.validations.last.status).to eq('pending')
              expect(user.validations.count).to eq(2)
            end
          end

          context 'when validation is not found' do
            before do
              post '/api/v1/users/password_recovery',
                   params: password_recovery_params
            end

            it 'sends password recovery email to user' do
              expect(response).to have_http_status(:ok)
              user.reload
              expect(user.validations.first.status).to eq('pending')
              expect(user.validations.count).to eq(1)
            end
          end
        end

        context 'when user is not found' do
          before do
            post '/api/v1/users/password_recovery'
          end

          it 'returns a not found response' do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe 'PUT update_password' do
        context 'when validation is found' do
          let(:user) { create(:user) }
          let(:token) { 'any_token' }
          let(:password) { 'new_password' }
          let(:update_password_params) do
            {
              user_id: user.id,
              password:,
              token:
            }
          end

          before do
            create(:validation,
                   user:,
                   validation_type: 'password_recovery',
                   status: 'pending')

            put "/api/v1/users/#{user.id}/update_password",
                params: update_password_params
          end

          it 'updates user password' do
            expect(response).to have_http_status(:ok)
            user.reload
            expect(user.password).to eq(password)
            expect(user.validations.last.status).to eq('used')
          end
        end

        context 'when validation is not found' do
          let(:user) { create(:user) }
          let(:token) { 'any_token' }
          let(:password) { 'new_password' }
          let(:update_password_params) do
            {
              user_id: user.id,
              password:,
              token:
            }
          end

          before do
            put "/api/v1/users/#{user.id}/update_password",
                params: update_password_params
          end

          it 'returns a not found response' do
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end
end
