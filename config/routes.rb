Rails.application.routes.draw do
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
  resources :destinations, only: [ :new, :create ]


  # ---------- 配達先リスト（DeliveryStops） ----------
  # 完了済み一覧ページ（index）と完了処理（complete）
  resources :delivery_stops, only: [ :index ] do
    member do
      patch :complete
      delete :destroy
    end
  end
end
