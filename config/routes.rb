# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :tenants
  resources :subscription_plans, only: %i[index]
  resources :subscriptions, only: %i[index]
  resources :companies
  resources :clients
  resources :product_types
  resources :products
  post '/authenticate', to: 'authentication#authenticate'
  post '/authenticate/company_auth/:company_id', to: 'authentication#company_auth'

  # Defines the root path route ("/")
  # root "posts#index"
end
