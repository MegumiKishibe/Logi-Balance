Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "settings/driver"
  get "settings/destination"
  # ---------- 基本設定 ----------
  root to: "sessions#new" # ホーム画面をログイン画面に設定

  get "login", to: "sessions#new"      # ログイン画面（表示）
  post "login", to: "sessions#create"  # ログイン処理（フォーム送信）
  delete "logout", to: "sessions#destroy"  # ログアウト処理


  # ---------- 配達（Deliveries） ----------
  resources :deliveries, only: [ :new, :create, :show ] do
    resources :delivery_stops, only: [ :new, :create ]
  end

  # ---------- 配達先（Destinations） ----------
  resources :destinations, only: [ :new, :create, :edit, :update ]

  # ---------- 配達先リスト（DeliveryStops） ----------
  resources :delivery_stops, only: [ :index ] do
    member do
      patch :complete
      delete :destroy
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
