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

  resources :users, :only => [:show, :create, :update, :destroy] do
    resources :orders
  end

  namespace :admin do
    resources :order_statuses do
      member do
        get :make_default
      end
    end

    resources :users do
      resources :orders
    end

    resources :products, only: [:create, :update] do
      resources :feedbacks
    end
    resources :categories do
      resources :products, except: [:create, :update] do
        resources :feedbacks
      end
    end
  end

  # add catch all routes for react rails
end
