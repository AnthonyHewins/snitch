Rails.application.routes.draw do
  resources :machines, only: [:index, :show]
end
