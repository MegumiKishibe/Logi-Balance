Rails.application.routes.draw do
  # ---------- Devise ----------
  devise_for :employees, skip: [ :registrations, :passwords ] # 管理権限上、新規登録とパスワードリセットは不要

  # ---------- 基本設定 ----------
  root to: "daily_course_runs#new" # ログイン後のトップを日次コース稼働登録画面に設定

  get "up" => "rails/health#show", as: :rails_health_check # ヘルスチェック用エンドポイント

  # ---------- 日次コース稼働（DailyCourseRunsController） ----------
  resources :daily_course_runs, only: [ :index, :new, :create, :show ] do
    member do
      patch :finish # 状態変更系追加アクション
    end

    collection do
      get :import        # CSVインポート画面表示
      post :import_create # CSVインポート実行
    end

    # 日次コース稼働に紐づく配達先実績の入力（ネスト：new/create）
    resources :daily_course_run_stops, only: [ :new, :create ]
  end

  # ---------- 配達先（Destinations） ----------
  resources :destinations, only: [ :new, :create, :edit, :update ]

  # ---------- 日次コース稼働の配達先実績一覧（DailyCourseRunStops） ----------
  resources :daily_course_run_stops, only: [ :index, :destroy ] do
    member do
      patch :complete
    end
  end

  # ---------- Dashboard ----------
  resources :dashboard, only: [] do
    collection do
      get :courses # /dashboard/courses
    end

    member do
      get :index   # /dashboard/:id
      get :daily   # /dashboard/:id/daily
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
