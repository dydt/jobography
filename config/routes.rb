Six470::Application.routes.draw do

  get "job/display"

  resources :users
  
  resources :user_sessions

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
