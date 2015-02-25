Rails.application.routes.draw do
  post '/match' => 'home#match'
  root 'home#index'
end
