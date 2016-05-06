Rails.application.routes.draw do
  devise_for :users,
             :controllers => {
               registrations: "users/registrations",
               sessions: "users/sessions"
             }

  get 'users', :to => 'users#index'

  resources :categories, param: :name, only: [:index, :show] do
    resources :products, only: [:index, :show] do
      resources :feedbacks, except: [:update]
    end
  end

  namespace :admin do
    resources :categories, param: :name do
      resources :products do
        resources :feedbacks
      end
      resources :categories, param: :name, path: '/' do
        resources :products do
          resources :feedbacks
        end
      end
    end
  end

  # add catch all routes for react rails
end
