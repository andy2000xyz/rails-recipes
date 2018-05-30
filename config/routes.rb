Rails.application.routes.draw do

  devise_for :users

  resources :events do
    resources :registrations
  end

  resource :user

  namespace :admin do
    root "events#index"
    resources :events do
      resources :tickets, :controller => "event_tickets"
        collection do
          post :bulk_update
        end

      member do
        post :reorder
      end
    end
    resources :categories
    resources :users do
      resource :profile, :controller => "user_profiles"
    end
  end



  get "/faq" => "pages#faq"


  root "events#index"

end
