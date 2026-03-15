# ER Diagram

ER図は dbdiagram（DBML）で管理しています。テーブル構造と関連の概要を示します。

- DBML（正本）: [docs/erd/schema.dbml](./erd/schema.dbml)

## 内容概要
- 第3正規形まで正規化済み


//以下、RUNTEQ卒業課題用追加事項
### 本サービスの概要（700文字以内）
Logi-Balanceは、配送コースごとの業務負荷を可視化し、負担の偏りを把握・改善するための物流現場向けWebアプリケーションです。
想定ユーザーは、配送コースの割り振りや日々の運行状況を管理する配車担当者・管理者です。
物流現場では、件数が同じでも配送先の密集度や荷物量、作業条件によって実際の負担が異なるため、経験や感覚に依存した判断では偏りが生まれやすい課題があります。
本サービスでは、配送実績データをもとに独自の負荷ポイントを算出し、コースごとの負荷を一覧・グラフで確認できます。
これにより、担当者が根拠を持ってコース調整を行えるようにし、業務負担の平準化と現場改善を支援します。

### MVPで実装する予定の機能
- 配送コース・配送先・車格の基本マスタ管理機能
- 従業員と配送コースの担当割当管理機能
- 日次コース運行データの登録・閲覧機能
- 配送先ごとの立寄実績登録機能
- 業務負荷スコアの算出・保存・閲覧機能
- 配送実績CSVの取込管理機能

### テーブル詳細

#### employees テーブル
- employee_no : integer / 従業員番号
- last_name_ja : string / 姓（日本語）
- first_name_ja : string / 名（日本語）
- last_name_en : string / 姓（英字）
- first_name_en : string / 名（英字）
- hired_on : date / 入社日

#### vehicle_types テーブル
- name : string / 車格名

#### destinations テーブル
- name : string / 配送先名
- address : string / 配送先住所

#### delivery_routes テーブル
- name : string / 配送コース名
- vehicle_type_id : integer / 対応する車格ID

#### delivery_route_destinations テーブル
- delivery_route_id : integer / 配送コースID
- destination_id : integer / 配送先ID  
- 配送コースと配送先の対応関係を管理する中間テーブル

#### employee_route_assignments テーブル
- employee_id : integer / 従業員ID
- delivery_route_id : integer / 配送コースID
- effective_from : date / 担当開始日
- effective_to : date / 担当終了日  
- 従業員がどの期間どのコースを担当していたかを管理するテーブル

#### daily_course_runs テーブル
- employee_id : integer / 当日の担当従業員ID
- delivery_route_id : integer / 実施した配送コースID
- service_date : date / 配送日
- started_at : datetime / 業務開始日時
- finished_at : datetime / 業務終了日時
- odo_start_km : integer / 出発時走行距離
- odo_end_km : integer / 帰着時走行距離  
- 日ごとの配送コース運行実績を管理するテーブル

#### daily_course_run_stops テーブル
- daily_course_run_id : integer / 日次運行ID
- destination_id : integer / 配送先ID
- stop_no : integer / 立寄順
- packages_count : integer / 荷物個数
- pieces_count : integer / 荷姿数
- completed_at : datetime / 対応完了日時  
- 1回の日次運行における配送先ごとの立寄実績を管理するテーブル

#### daily_course_run_score_snapshots テーブル
- daily_course_run_id : integer / 日次運行ID
- work_score : integer / 作業量スコア
- density_score : decimal / 密集度スコア
- total_score : integer / 総合負荷スコア
- calculated_at : datetime / 算出日時  
- 算出時点の負荷スコアを保存し、後から参照できるようにするスナップショットテーブル

#### csv_imports テーブル
- file_hash : string / 取込ファイルの識別用ハッシュ
- filename : string / 取込ファイル名
- status : integer / 取込ステータス
- error_message : text / エラー内容
- created_at : datetime / 作成日時
- updated_at : datetime / 更新日時  
- 配送実績CSVの取込履歴を管理するテーブル

### ER図の注意点
- [ ] 最新のER図スクリーンショットがPRに掲載されているか
- [ ] `employees` `delivery_routes` `destinations` など、テーブル名は複数形で統一されているか
- [ ] すべてのカラムに型が記載されているか
- [ ] `vehicle_type_id` `employee_id` `delivery_route_id` `destination_id` `daily_course_run_id` などの外部キーが適切に設定されているか
- [ ] `delivery_routes` - `vehicle_types`、`daily_course_runs` - `employees`、`daily_course_run_stops` - `destinations` などのリレーションが正しく描かれているか
- [ ] 多対多の関係は `delivery_route_destinations` や `employee_route_assignments` などの中間テーブルで解消できているか
- [ ] STIは使用していないか
- [ ] `delivery_routes` テーブルに `delivery_route_name` のような重複した命名をしていないか
- [ ] 負荷スコアは `daily_course_run_score_snapshots` に分離し、日次運行実績と役割を分けて管理できているか
- [ ] CSV取込履歴は `csv_imports` として独立しており、業務実績テーブルと責務が分離されているか