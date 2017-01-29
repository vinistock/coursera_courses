Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :states, except: [:new, :edit]
    resources :cities, except: [:new, :edit]
    resources :foos, except: [:new, :edit]
    resources :bars, except: [:new, :edit]
  end

  root 'ui#index'
  get '/ui' => 'ui#index'
  get '/ui#' => 'ui#index'
end
