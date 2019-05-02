Rails.application.routes.draw do
  get 'drligma' => 'static#drligma'
  get 'tball' => 'static#tball'
  
  get "logout" => "sessions#destroy"
  get "login" => "sessions#new"
  post "login" => "sessions#create"

  %i(machines uri_entries users whitelists).each do |i|
    get "#{i}/upload" => "#{i}#upload"
    post "#{i}/upload" => "#{i}#insert_data"
  end

  get 'uri_entries/refresh' => 'uri_entries#pull_from_cyberadapt'
  get 'cyber_adapt_alerts/refresh' => 'cyber_adapt_alerts#pull_from_exchange'
  get 'fs_isac_alerts/refresh' => 'fs_isac_alerts#pull_from_exchange'

  resources :users
  resources :whitelists, only: [:index]
  resources :uri_entries, only: [:index]
  resources :machines, only: [:index, :edit, :update]
  resources :fs_isac_ignores

  %i(cyber_adapt_alerts fs_isac_alerts).each do |sym|
    resources sym, except: %i(new create) do
      get 'set_booleans', on: :member
    end
  end

  root 'static#index'
end
