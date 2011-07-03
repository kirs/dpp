Dpp::Application.routes.draw do
  get "about" => "about#developer", :as => 'about'
  get "api" => "about#api_info", :as => 'api_info'
  
  match 'find' => 'requests#find'
  resources :request_logs, :only => :index, :path => "/logs"
  
  root :to => "requests#index"
end
