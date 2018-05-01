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
  resources :flights
  resources :airlines, only: [:index, :edit, :update]
  resources :airports, only: [:index, :edit, :update]
  
  # Certbot
  get '/.well-known/acme-challenge/:id' => 'static_pages#letsencrypt'
  
end