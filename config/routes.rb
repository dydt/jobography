Six470::Application.routes.draw do

  resources :jobs

  resources :users
  
  resources :user_sessions

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
