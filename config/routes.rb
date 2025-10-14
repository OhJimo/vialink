Rails.application.routes.draw do
  devise_for :users
  mount Motor::Admin => "/motor_admin"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authenticated users go to dashboard, guests to link creation
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  root "links#new"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Links
  resources :links, only: [ :new, :create, :show, :destroy ]

  # Short URL route - must be last
  get "/:code", to: "links#show", as: :short_link
end
