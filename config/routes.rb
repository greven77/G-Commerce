Rails.application.routes.draw do
  devise_for :users,
             :controllers => {
               registrations: "users/registrations",
               sessions: "users/sessions"
             }

  get 'users', :to => 'users#index'

  resources :products do
    resources :feedbacks, except: [:update]
  end

  namespace :admin do
    resources :categories do
      resources :products do
        resources :feedbacks
      end
    end
  end

  # add catch all routes for react rails
end
