Rails.application.routes.draw do
  resources :lookup_table_records
  post '/match' => 'home#match'
  root 'home#index'
end
