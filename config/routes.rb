Six470::Application.routes.draw do

  match "search/:query" => "search#search"
  match "search" => "search#search", :as => :search

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks"}

  resources :jobs
  
  match 'jobs/:id/json' => 'jobs#json'

  resources :users

  get "home/welcome"
  
  root :to => "home#home"
  
end
