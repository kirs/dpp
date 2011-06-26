Dpp::Application.routes.draw do
  get "about" => "about#developer", :as => 'about'
  get "api" => "about#api_info", :as => 'api_info'
  
  # config/routes.rb
  #resources :requests, :only => [:new, :create]
  
  match 'find' => 'requests#find'
  resources :request_logs, :only => :index
  
  root :to => "requests#index"
end
