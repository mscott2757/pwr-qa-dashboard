Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :tests do
    get 'edit', on: :member
  end
  resources :application_tags do
    collection do
      get 'edit'
      get 'edit_app_col'
      get 'edit_test_col'
    end
  end

  get '/environment_tags/select_env/:id', to: 'environment_tags#select_environment', as: 'change_env'
  get '/environment_tags/toggle_rotate', to: 'environment_tags#toggle_rotate', as: 'toggle_rotate'

  root to: 'application_tags#index'
end
