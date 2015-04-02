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
    resources :products do
      get :search, on: :collection
      post :recount, on: :member
    end
    resources :categories,  except: [:show]
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
