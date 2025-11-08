Rails.application.routes.draw do
  get "destinations/new"
  get "destinations/create"
  root to: "sessions#new" # ホーム画面をログイン画面に設定

  get "login", to: "sessions#new"  # ログイン画面（表示）
  post "login", to: "sessions#create"  # ログイン処理（フォーム送信）
  delete "logout", to: "sessions#destroy"  # ログアウト処理

  resources :deliveries, only: [ :new, :create, :show ] # 配達記録画面のルーティング
  resources :delivery_stops, only: [ :new, :create ] # 配達先到着画面のルーティング
  resources :destinations, only: [ :new, :create ] # 配達先登録画面のルーティング
end
