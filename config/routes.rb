Six470::Application.routes.draw do

  resources :jobs
  
  match 'jobs/:id/json' => 'jobs#json'

  resources :users
  
  match 'login' => 'user_sessions#new'
  
  match 'logout' => 'user_sessions#destroy'
  
  resource :user_session, :only => [:new, :create, :destroy]

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
