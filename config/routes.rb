# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :tenants do
    post :address, to: 'tenants#create_address'
    put 'address/:address_id', to: 'tenants#update_address', as: :update_address
  end
  resources :companies do
    post :address, to: 'companies#create_address'
    put 'address/:address_id', to: 'companies#update_address', as: :update_address
  end
  resources :clients do
    post :address, to: 'clients#create_address'
    put 'address/:address_id', to: 'clients#update_address', as: :update_address
  end
  resources :product_types
  resources :products
  post '/authenticate', to: 'authentication#authenticate'
  post '/authenticate/company_auth/:company_id', to: 'authentication#company_auth'

  # Defines the root path route ("/")
  # root "posts#index"
end
