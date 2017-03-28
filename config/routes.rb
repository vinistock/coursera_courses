Rails.application.routes.draw do
  get 'authn/whoami', defaults: { format: :json }
  get 'authn/checkme'

  mount_devise_token_auth_for 'User', at: 'auth'

  scope :api, defaults: { format: :json } do
    resources :states, except: [:new, :edit]
    resources :cities, except: [:new, :edit]
    resources :foos, except: [:new, :edit]
    resources :bars, except: [:new, :edit]
    resources :images, except: [:new, :edit] do
      post 'thing_images', controller: :thing_images, action: :create
      get 'thing_images', controller: :thing_images, action: :image_things
      get 'linkable_things', controller: :thing_images, action: :linkable_things
    end

    resources :things, except: [:new, :edit] do
      resources :thing_images, only: [:index, :create, :update, :destroy]
    end
  end

  root 'ui#index'
  get '/ui' => 'ui#index'
  get '/ui#' => 'ui#index'
end
