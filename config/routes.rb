Rails.application.routes.draw do
  
  root 'static_pages#home'
  
  get     'admin'  => 'static_pages#admin'
  
  get     'signup' => 'users#new'
  
  get     'login'  => 'sessions#new'
  post    'login'  => 'sessions#create'
  delete  'logout' => 'sessions#destroy'
  
  post    'share_link/:id', to: 'events#update_share_link', as: 'update_share_link'
  
  get     'events/:id/share/:share_link' => 'events#show'
  
  resources :users
  resources :events
  resources :travelers
  get  "travelers/:id/new-flight-search" => "travelers#new_flight_search", as: :new_flight_search
  post "travelers/:id/new-flight-select" => "travelers#new_flight_select", as: :new_flight_select
  
  resources :flights
  resources :airlines, only: [:index, :edit, :update]
  resources :airports, except: [:show]
  
  # Certbot
  get '/.well-known/acme-challenge/:id' => 'static_pages#letsencrypt'
  
end