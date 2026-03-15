# ER Diagram

ER図は dbdiagram（DBML）で管理しています。テーブル構造と関連の概要を示します。

- DBML（正本）: [docs/erd/schema.dbml](./erd/schema.dbml)

## 内容概要
- 配送コース、配送先、従業員、日次運行実績、負荷スコア、CSV取込履歴を中心としたデータ構造です
- 多対多の関係は中間テーブルで解消しています
- 第3正規形を意識して設計しています