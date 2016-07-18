Rails.application.routes.draw do
  
  root 'static_pages#home'
  
  get     'admin'  => 'static_pages#admin'
  
  get     'signup' => 'users#new'
  
  get     'login'  => 'sessions#new'
  post    'login'  => 'sessions#create'
  delete  'logout' => 'sessions#destroy'
  
  post    'share_link/:id', to: 'events#share_link', as: 'share_link'
  
  get     'events/:id/share/:share_link' => 'events#show'
  
  resources :users
  resources :events
  resources :sections
  resources :flights
  resources :airlines, only: [:index, :edit, :update]
  
  get 'events/show2/:id' => 'events#show2'
  
end
