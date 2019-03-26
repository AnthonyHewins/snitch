Rails.application.routes.draw do
  get 'drligma' => 'static#drligma'
  
  %i(machines uri_entries users whitelists).each do |i|
    get "#{i}/upload" => "#{i}#upload"
    post "#{i}/upload" => "#{i}#insert_data"
  end

  get 'uri_entries/refresh' => 'uri_entries#pull_from_cyberadapt'
  
  resources :whitelists, only: [:index]
  resources :uri_entries, only: [:index]
  resources :machines, only: [:index]

  root 'static#index'
end
