Six470::Application.routes.draw do

  devise_for :users

  resources :jobs
  
  match 'jobs/:id/json' => 'jobs#json'

  resources :users

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
