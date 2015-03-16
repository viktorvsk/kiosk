Rails.application.routes.draw do
  root 'products#index'
  devise_for :users
  mount Ckeditor::Engine => '/ckeditor'
  resources :products,    only: [:index, :show]
  resources :categories,  only: [:index, :show]
  resources :orders
  resource :user, only: [:edit, :update]


  namespace :admin do
    root 'products#index'
    resources :products,    except: [:show]
    resources :categories,  except: [:show]
    resources :confs,       except: [:show]
    resources :markups,     except: [:show]
    resources :orders,      except: [:show]
    resources :users,       except: [:show]
    namespace :vendor do
      resources :merchants, except: [:show]
    end
  end
end
