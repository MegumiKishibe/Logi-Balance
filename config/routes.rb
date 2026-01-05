Rails.application.routes.draw do
  # ---------- Devise ----------
  devise_for :employees, skip: [ :registrations, :passwords ]

  # ---------- 基本設定 ----------
  root to: "deliveries#new" # ログイン後のトップを配達登録画面に設定

  get "up" => "rails/health#show", as: :rails_health_check

  # ---------- 配達（Deliveries） ----------
  resources :deliveries, only: [ :index, :new, :create, :show ] do
    patch :finish, on: :member # /deliveries/:id/finish
    resources :delivery_stops, only: [ :new, :create ]
  end

  # ---------- 配達先（Destinations） ----------
  resources :destinations, only: [ :new, :create, :edit, :update ]

  # ---------- 配達先リスト（DeliveryStops） ----------
  resources :delivery_stops, only: [ :index, :destroy ] do
    member do
      patch :complete
    end
  end

  # ---------- Dashboard ----------
  resources :dashboard, only: [] do
    collection do
      get :courses      # /dashboard/courses
    end

    member do
      get :index        # /dashboard/:id
      get :daily        # /dashboard/:id/daily
    end
  end

  # ---------- Analytics ----------
  resource :analytics, only: [] do
    get :index
    get :weekly
    get :monthly
  end

  # ---------- Settings -----------
  resources :settings, only: [ :index ] do
    collection do
      get :driver
      post :update_driver
      get :destination
      post :update_destination
    end
  end
end
