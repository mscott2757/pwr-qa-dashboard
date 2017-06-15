Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :tests
  resources :application_tags do
    get 'edit', on: :collection
  end

  get '/settings/:id', to: 'settings#select_environment', as: 'change_env'

  root to: 'application_tags#index'
end
