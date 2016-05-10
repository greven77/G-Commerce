Rails.application.routes.draw do
  devise_for :users,
             :controllers => {
               registrations: "users/registrations",
               sessions: "users/sessions"
             }

  get 'users', :to => 'users#index'

  resources :categories, only: [:index, :show] do
    resources :products, only: [:index, :show] do
      resources :feedbacks, except: [:update]
    end
  end

  namespace :admin do
    resources :products, only: [:create, :update]
    resources :categories do
      resources :products, except: [:create, :update] do
        resources :feedbacks
      end
    end
  end

  # add catch all routes for react rails
end
