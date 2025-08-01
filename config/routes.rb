Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :settings, only: [ :show, :update ], as: :settings
  resources :clients
  resources :orders do
    collection do
      get :shipping_addresses
    end
    member do
      patch :update_status
      patch :update_file_metadata
      delete "attachments/:attachment_id", to: "orders#delete_attachment", as: :attachment
    end
    resources :chat_messages, only: [ :index, :create ] do
      collection do
        get :users_for_mention
      end
    end
  end
  resources :user_invitations, only: [ :create, :destroy ]
  get "activate/:token", to: "user_activations#new", as: :activate_user_invitation
  post "activate/:token", to: "user_activations#create"
  resources :items do
    collection do
      get :search
    end
  end
  get "fab" => "fab#index"
  get "delivery" => "delivery#index"
  get "relations" => "relations#index"

  # Letter opener for development email preview
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
