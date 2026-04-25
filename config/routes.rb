Rails.application.routes.draw do
  resource :profile, only: %i[new create edit update] do
    patch :request_creator
    patch :request_professional
  end
  resources :profiles, only: [] do
    patch :toggle_creator, on: :member
    patch :toggle_professional, on: :member
  end
  namespace :admin do
    resources :creator_requests, only: :index
    resources :formats, only: :index
    resources :profiles, only: :index
    resources :users, only: :index
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
  scope :posturacorretta do
    get "mappa", to: "posturacorretta#mappa", as: :posturacorretta_mappa
    get "aree", to: "posturacorretta#aree", as: :posturacorretta_aree
    get "ambiti", to: "posturacorretta#ambiti", as: :posturacorretta_ambiti
    get "medicina-semplici", to: "posturacorretta#medicina", as: :posturacorretta_medicina
    get "oriente-occidente", to: "posturacorretta#oriente_occidente", as: :posturacorretta_oriente_occidente
    get "contenuti", to: "posturacorretta#contenuti", as: :posturacorretta_contenuti
    get "corsi-online", to: "posturacorretta#corsi_online", as: :posturacorretta_corsi_online
    get "manifesto", to: "posturacorretta#manifesto", as: :posturacorretta_manifesto
    get "eventi", to: "posturacorretta#eventi", as: :posturacorretta_eventi
    get "servizi", to: "posturacorretta#servizi", as: :posturacorretta_servizi
    get "rete", to: "posturacorretta#rete", as: :posturacorretta_rete
    get "persone", to: "posturacorretta#persone", as: :posturacorretta_persone
    get "rete-professionale", to: "posturacorretta#rete_professionale", as: :posturacorretta_rete_professionale
    get "professionisti", to: redirect("/posturacorretta/rete-professionale")
    get "centri", to: "posturacorretta#centri", as: :posturacorretta_centri
    get "metodiche", to: "posturacorretta#metodiche", as: :posturacorretta_metodiche
  end
  get "creator/carta_nautica", to: "creator#carta_nautica", as: :creator_carta_nautica
  get "creator/carta_nautica/brands/:brand_port_id", to: "creator#carta_nautica", as: :creator_brand_carta_nautica
  get "creator/albero_brand", to: "creator#brand_tree", as: :creator_brand_tree
  get "creator/branch_map", to: "creator#branch_map", as: :creator_branch_map
  get "creator/journey", to: "creator#journey", as: :creator_journey
  get "creator/value_architecture", to: "creator#value_architecture", as: :creator_value_architecture

  namespace :creator do
    resources :ports, only: [ :show, :new, :create, :edit, :update, :destroy ] do
      get :land_map, on: :member
      post :land_map_station, on: :member, to: "stations#create_from_land_map"
      get :preview, on: :member
      resource :content, only: [ :new, :create, :edit, :update ]
      resources :experiences, except: :show
      resources :lines, except: :show do
        resources :stations, except: :show
        patch "stations/:id/reposition", to: "stations#reposition", as: :reposition_station
      end
      resources :webapp_domains, except: :show do
        patch :toggle_published, on: :member
      end
    end
    resources :sea_routes, only: [ :create, :update, :destroy ] do
      patch :cycle_direction, on: :member
      patch :invert_direction, on: :member
      patch :set_direction, on: :member
    end
  end

  get "traveler/impegno", to: "traveler#impegno", as: :traveler_impegno
  get "traveler/ticket_calendar", to: "traveler#ticket_calendar", as: :traveler_ticket_calendar
  get "traveler/journey_calendar", to: "traveler#journey_calendar", as: :traveler_journey_calendar
  get "professionals", to: "professionals#index", as: :professionals
  get "professionals/catalog", to: "professionals#catalog", as: :professionals_catalog
  get "professionals/value", to: "professionals#value", as: :professionals_value
  get "professionals/titles", to: "professionals#titles", as: :professionals_titles
  resource :dashboard, only: :show do
    patch :workspace
  end
  get "hub", to: "pages#hub", as: :hub_dashboard
  get "hobby_obiettivi", to: "pages#hobby_goals", as: :hobby_goals
  get "percorsi_in_atto", to: "pages#active_paths", as: :active_paths
  get "eventi_condivisi", to: "pages#shared_events", as: :shared_events
  get "about", to: "pages#about", as: :about
  get "fondatore", to: "pages#fondatore", as: :fondatore
  get "markpostura", to: "pages#markpostura", as: :markpostura
  get "week_plan", to: "pages#week_plan", as: :week_plan
  get "daily_plan", to: "pages#daily_plan", as: :daily_plan
  get "prenota", to: "pages#prenotazioni", as: :public_prenotazioni
  get "brand-homes/posturacorretta-home", to: "brand_homes#posturacorretta_home", as: :posturacorretta_brand_home
  get "ports/:id/public", to: "ports#public", as: :public_port
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post
  root "pages#home"
end
