Rails.application.routes.draw do
  get 'drligma' => 'static#drligma'
  
  get 'machines/upload' => 'machines#upload'
  get 'uri_entries/upload' => 'uri_entries#upload'
  post 'machines/upload' => 'machines#insert_data'
  post 'uri_entries/upload' => 'uri_entries#insert_data'

  get 'uri_entries/refresh' => 'uri_entries#pull_from_cyberadapt'
  
  resources :uri_entries, only: [:index, :show]
  resources :machines, only: [:index, :show]

  root 'static#index'
end
