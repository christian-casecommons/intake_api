# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :participants, only: %i[create destroy update]
      resources :people
      resources :people_search, only: [:index]
      resources :screenings do
        member do
          get :history_of_involvements
          get :relationships
          post :submit
        end
      end
    end
    namespace :v2 do
      resources :people_search, only: [:index]
    end
  end

  resources :version, only: :index

  scope host: ENV.fetch('SEARCH_URL') do
    post '/api/v1/referrals' => 'dev#null', as: :tpt_api_v1_referrals
  end
end
