Six470::Application.routes.draw do

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks"}

  resources :jobs
  
  match 'jobs/:id/json' => 'jobs#json'

  resources :users

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
