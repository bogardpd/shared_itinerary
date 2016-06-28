Rails.application.routes.draw do
  
  root 'static_pages#home'
  
  get     'signup' => 'users#new'
  
  get     'login' => 'sessions#new'
  post    'login' => 'sessions#create'
  delete  'logout' => 'sessions#destroy'
  
  post    'share_link/:id', to: 'events#share_link', as: 'share_link'
  
  get     'events/:id/share/:share_link' => 'events#show'
  
  resources :users
  resources :events
  resources :sections
  resources :flights
  
end
