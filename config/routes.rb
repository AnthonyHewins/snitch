Rails.application.routes.draw do
  get 'drligma' => 'static#drligma'
  get 'tball' => 'static#tball'
  
  get "logout" => "sessions#destroy"
  get "login" => "sessions#new"
  post "login" => "sessions#create"

  %w(machines uri_entries whitelists).each do |i|
    get "#{i}/upload" => "#{i}#upload"
    post "#{i}/upload" => "#{i}#insert_data"
  end

  get 'uri_entries/refresh' => 'uri_entries#pull_from_cyberadapt'
  get 'cyber_adapt_alerts/refresh' => 'cyber_adapt_alerts#pull_from_exchange'
  get 'fs_isac_alerts/refresh' => 'fs_isac_alerts#pull_from_exchange'
  get 'ms_isac_blacklist/refresh' => 'ms_isac_blacklist#pull_from_exchange'

  resources :uri_entries, only: [:index]
  resources :machines, except: [:show]
  resources :fs_isac_ignores
  resources :whitelists

  resources :fs_isac_alerts, except: %i(new) do
    get 'set_booleans', on: :member
    get 'error', on: :collection
  end

  root 'static#index'
end
