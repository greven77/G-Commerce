Rails.application.routes.draw do
  devise_for :users,
             :controllers => {
               registrations: "users/registrations",
               sessions: "users/sessions"
             }

  get 'users', :to => 'users#index'

  resources :categories, only: [:index, :show] do
    resources :products, only: [:index, :show] do
      resources :feedbacks, except: [:update, :show]
    end
  end

  resources :users, :only => [:show, :create, :update]

  resources :customers, :only => [:show, :create, :update] do
    resources :orders
  end

  resources :countries, :only => [:index]

  match 'cart' => 'carts#show', :via => :get
  match 'cart' => 'carts#destroy', :via => :delete
  match 'cart/increase/:product_id' => 'carts#increase_product_quantity', :via => :put
  match 'cart/decrease/:product_id' => 'carts#decrease_product_quantity', :via => :put
  match 'cart/set_quantity/:product_id' => 'carts#increase_product_quantity', :via => :put
  match 'cart/remove/:product_id' => 'carts#remove_product', :via => :put

  namespace :admin do
    resources :order_statuses do
      member do
        get :make_default
      end
    end

    resources :countries

    resources :customers do
      resources :orders
    end

    resources :users

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
