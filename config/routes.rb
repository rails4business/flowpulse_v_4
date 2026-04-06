Rails.application.routes.draw do
  resource :profile, only: %i[new create edit update] do
    patch :request_creator
  end
  resources :profiles, only: [] do
    patch :toggle_creator, on: :member
  end
  namespace :admin do
    resources :creator_requests, only: :index
  end
  resource :registration, only: %i[new create]
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "creator/map_index", to: "creator#map_index", as: :creator_map_index
  get "creator/branch_map", to: "creator#branch_map", as: :creator_branch_map
  get "creator/journey", to: "creator#journey", as: :creator_journey
  get "creator/value_architecture", to: "creator#value_architecture", as: :creator_value_architecture

  get "traveler/impegno", to: "traveler#impegno", as: :traveler_impegno
  get "traveler/ticket_calendar", to: "traveler#ticket_calendar", as: :traveler_ticket_calendar
  get "traveler/journey_calendar", to: "traveler#journey_calendar", as: :traveler_journey_calendar
  get "professionals", to: "professionals#index", as: :professionals
  get "professionals/catalog", to: "professionals#catalog", as: :professionals_catalog
  get "professionals/value", to: "professionals#value", as: :professionals_value
  get "professionals/titles", to: "professionals#titles", as: :professionals_titles
  resource :dashboard, only: :show
  get "about", to: "pages#about", as: :about
  root "pages#home"
end
