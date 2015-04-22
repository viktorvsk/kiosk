Rails.application.routes.draw do
  root 'products#index'
  get :admin, to: 'admin/vendor/merchants#index'
  devise_for :users

  mount Ckeditor::Engine => '/ckeditor'
  resources :products,     only: [:index, :show] do
    collection do
      get :search
    end
  end
  resources :categories, only: [:index, :show]
  resources :orders
  resource :user, only: [:edit, :update]

  namespace :admin do
    post 'binding/:product_id/:vendor_product_id', to: 'binding#bind'
    delete 'binding/:vendor_product_id', to: 'binding#unbind'
    namespace :autocomplete do
      get :properties
    end
    resources :products do
      member do
        post :update_from_marketplace
        post :recount
        post :copy_filters
        post :copy_properties
        patch 'product_filter_values/:pfv_id', to: 'products#update_product_filter_value', as: :update_pfv
      end
      collection do
        get :search
        get :search_marketplaces
        post :create_from_marketplace
      end
      resources :product_properties, only: [:create, :update] do
        member do
          patch :update, to: 'properties#update_product_property', as: :update
          delete :destroy, to: 'properties#destroy_product_property', as: :destroy
        end
        collection do
          post :create, to: 'properties#create_product_property', as: :create
        end
      end
      resources :properties, only: [:create, :destroy] do
        collection do
          patch :reorder_product
        end
      end

    end
    resources :categories, except: [:show] do
      post :reorder_all_properties
      post :reorder_filters
      post :add_filter
      post :add_filter_value
      delete 'remove_filter/:filter_id', to: 'categories#remove_filter', as: :remove_filter
      delete 'remove_filter_value/:filter_value_id', to: 'categories#remove_filter_value', as: :remove_filter_value
      resources :properties, only: [] do
        member do
          delete :'destroy_category_property', as: :destroy
        end
        collection do
          post :create_category_property, as: :create

          patch :reorder_category
          post :reorder_category_all
        end
      end
      collection do
        get :search
      end
    end

    resources :brands, except: [:show] do
      collection do
        get :search
      end
    end
    resources :confs, except: [:show]
    resources :markups, except: [:show]
    resources :orders, except: [:show]
    resources :users, except: [:show]
    namespace :vendor do
      resources :products, only: [:index, :show, :update] do
        get :search, on: :collection
        post :toggle_activation, on: :member
      end
      resources :merchants, except: [:show] do
        post :pricelist, on: :member
      end
    end
  end
  ActiveAdmin.routes(self)

end
