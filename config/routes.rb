Rails.application.routes.draw do
  get 'authn/whoami'
  get 'authn/checkme'

  mount_devise_token_auth_for 'User', at: 'auth'

  scope :api, defaults: { format: :json } do
    resources :states, except: [:new, :edit]
    resources :cities, except: [:new, :edit]
    resources :foos, except: [:new, :edit]
    resources :bars, except: [:new, :edit]
    resources :images, except: [:new, :edit]
    resources :things, except: [:new, :edit]
  end

  root 'ui#index'
  get '/ui' => 'ui#index'
  get '/ui#' => 'ui#index'
end
