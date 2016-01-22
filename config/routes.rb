Rails.application.routes.draw do
  get 'robots.txt', to: 'catalog#robots'
  get 'sitemap.xml', to: 'catalog#sitemap'
  get 'price_full.xml', to: 'catalog#price'
  root 'products#index'
  get :admin, to: 'admin/base#dashboard'
  devise_for :users

  mount Ckeditor::Engine => '/ckeditor'

  get '/products/:slug', to: 'products#old_show'

  get 'pages/(:slug)/:id', to: 'catalog#static_page', as: :static_page
  get 'help', to: 'catalog#help_pages', as: :help_pages
  get 'help/:slug/:id', to: 'catalog#show_help_page', as: :help_page

  get '/p/:slug/:id', to: 'products#show', as: :p
  get '/t/:slug/:id', to: 'taxons#show', as: :t
  get '/c/:id/compare', to: 'categories#compare', as: :compare
  get '/c/:slug/:id', to: 'categories#show', as: :c
  post '/c/:id/compare/:product_id', to: 'categories#add_to_compare', as: :add_to_compare
  delete '/c/:id/compare/:product_id', to: 'categories#remove_from_compare', as: :remove_from_compare

  resources :products, only: [:index, :show], path: 'p' do
    post :comment, to: 'products#add_comment', as: :comment
    collection do
      get :search
    end
  end
  resources :categories, only: [:index, :show], path: 'c', id: /\d+/
  resources :taxons, only: [:show], path: 't'
  resource :order, only: [:show, :update] do
    post :checkout
    patch 'update_lineitem_count', to: 'orders#update_lineitem_count', as: :update_lineitem_count
    post 'add_product/:product_id', to: 'orders#add_product', as: :add_product
    delete 'remove_product/:product_id', to: 'orders#remove_product', as: :remove_product
  end
  resource :user, only: [:show, :update] do
    post :callback
  end

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
    resources :confs, only: [:index, :update]
    resources :markups, except: [:show]
    resources :orders, except: [:show] do
      get :search, on: :collection
    end
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
    resources :callbacks, except: [:new, :create, :show]
  end
  ActiveAdmin.routes(self)
end
