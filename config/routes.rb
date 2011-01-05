Six470::Application.routes.draw do
  get "job/display"

  resources :users

  get "home/welcome"
  
  root :to => "home#welcome"
  
end
