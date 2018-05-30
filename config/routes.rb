Rails.application.routes.draw do

  devise_for :users

  resources :events

  resource :user

  namespace :admin do
    root "events#index"
    resources :events
    resources :categories
  end

  get "/faq" => "pages#faq"


  root "events#index"

end
