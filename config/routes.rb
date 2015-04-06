Rails.application.routes.draw do
  root 'products#index'
  devise_for :users
  # mount Ckeditor::Engine => '/ckeditor'
  resources :products,    only: [:index, :show]
  resources :categories,  only: [:index, :show]
  resources :orders
  resource :user, only: [:edit, :update]

  namespace :admin do
    root 'vendor/merchants#index'
    post 'binding/:product_id/:vendor_product_id', to: 'binding#bind'
    delete 'binding/:vendor_product_id', to: 'binding#unbind'
    namespace :autocomplete do
      get :properties
    end
    resources :products do
      resources :product_properties, only: [:create, :update] do
        member do
          patch :update, to: 'properties#update_product_property', as: :update
          delete :destroy, to: 'properties#destroy_product_property', as: :destroy
        end
        post :create, to: 'properties#create_product_property', on: :collection, as: :create

      end
      resources :properties, only: [:create, :destroy] do
        collection do
          patch :reorder_product
        end
      end
      get :search, on: :collection
      post :recount, on: :member
    end
    resources :categories,  except: [:show] do
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
    end
    resources :confs,       except: [:show]
    resources :markups,     except: [:show]
    resources :orders,      except: [:show]
    resources :users,       except: [:show]
    namespace :vendor do
      resources :products, only: [:index, :show] do
        get :search, on: :collection
        post :toggle_activation, on: :member
      end
      resources :merchants, except: [:show] do
        post :pricelist, on: :member
      end
    end
  end

end
