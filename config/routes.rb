Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :tests
  resources :application_tags do
    get 'edit', on: :collection
  end
  root to: 'application_tags#index'
end
