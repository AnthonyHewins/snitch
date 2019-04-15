Rails.application.routes.draw do
  get 'drligma' => 'static#drligma'
  
  %i(machines uri_entries users whitelists).each do |i|
    get "#{i}/upload" => "#{i}#upload"
    post "#{i}/upload" => "#{i}#insert_data"
  end

  get 'uri_entries/refresh' => 'uri_entries#pull_from_cyberadapt'
  get 'cyber_adapt_alerts/refresh' => 'cyber_adapt_alerts#pull_from_exchange'
  get 'fs_isac_alerts/refresh' => 'fs_isac_alerts#pull_from_exchange'

  resources :whitelists, only: [:index]
  resources :uri_entries, only: [:index]
  resources :machines, only: [:index]

  %i(fs_isac_alerts cyber_adapt_alerts).each do |alert_type|
    resources alert_type, except: %i(new create) do
      get 'set_resolved', on: :member
    end
  end

  root 'static#index'
end
