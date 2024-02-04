# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :tenants, except: %i[new edit]
  resources :subscription_plans, except: %i[new edit]
  resources :users, only: %i[show update] do
    put :activate
    put :update_password
    collection do
      post :password_recovery
    end
  end
  resources :system_configurations, only: %i[show update] do
    collection do
      get :maintenance_mode
    end
  end
  resources :subscriptions, only: %i[index create]
  resources :companies, except: %i[new edit]
  resources :clients, except: %i[new edit]
  resources :product_types, except: %i[new edit]
  resources :products, except: %i[new edit]
  resources :employees, except: %i[new edit]
  resources :email_templates, only: %i[update show index]
  resources :company_email_templates, only: %i[update show index]
  post '/authenticate', to: 'authentication#authenticate'
  post '/authenticate/company_auth/:company_id', to: 'authentication#company_auth'
  post '/authenticate/logout_company_auth', to: 'authentication#logout_company_auth'
end
