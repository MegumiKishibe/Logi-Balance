# Logi-Balance

![Logi-Balance README Hero](assets/images/readme-hero.png)
配送業務の“負荷”を、感覚からデータへ。

配達コースごとの負担（件数・個数・距離など）の偏りをスコア化・可視化し、公平な配分判断を支援する業務改善ツールです。

## 主な機能（MVP）
- 実績（Deliveries）登録・一覧
- 配達先リスト（DeliveryStops）登録、完了時刻の記録
- 負担スコア（Work / Density / Total）の算出・表示
- ダッシュボード（日付単位でページングして日別比較）
- CSV出力（初版）

## 技術スタック
- Ruby on Rails / MySQL
- HTML / CSS / JavaScript
- Chartkick / Chart.js

## ドキュメント
- 設計資料一覧： [docs/README.md](docs/README.md)
- 要件定義書： [docs/_proposal.md](docs/_proposal.md)

## 認証について（Employees）
- 従業員アカウントは管理者が作成・管理します（自己登録はしません）。
- メールアドレスを利用しない運用のため、パスワード再設定は提供せず、管理者が再発行します。

