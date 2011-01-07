Six470::Application.routes.draw do

  resources :jobs

  resources :users
  
  resource :user_session, :only => [:new, :create, :destroy]

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
