Rails.application.routes.draw do
  root 'products#index'
  devise_for :users
  mount Ckeditor::Engine => '/ckeditor'
  resources :products, only: [:index, :show]


  namespace :admin do
    root 'products#index'
    resources :products, except: [:show]
  end
end
