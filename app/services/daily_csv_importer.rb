require "csv"
require "digest"

class DailyCsvImporter
  EXPECTED_HEADER = [ "日付", "従業員コード", "コース", "開始時刻", "開始指針", "終了指針", "配達先", "住所", "件数", "個数", "完了時間" ].freeze

  def initialize(file)
    @file = file
  end

  def call
    begin

      file_hash = sha256(@file)

      if CsvImport.success.exists?(file_hash: file_hash)
        return failure_result("このCSVファイルは既にインポートされています!ファイルを確認してください。")
      end

      import = CsvImport.find_or_initialize_by(file_hash: file_hash)

      import.filename = @file.original_filename
      import.status = :processing
      import.error_message = nil
      import.save!

      text = read_as_utf8(@file) #ファイルの内容をUTF-8エンコードのテキストとして読み込む
      rows = CSV.parse(text, headers: true) #テキストをCSV形式で解析し、行ごとに配列として取得する。ヘッダー行は自動的にスキップされる
      #ヘッダー確認
      if rows.headers != EXPECTED_HEADER #ヘッダーが期待される項目と一致しない場合は処理しない
        return failure_result("CSVの項目名が正しくありません!1行目（ヘッダー）を確認してください。")
      end
      #データがあるか確認
      if rows.empty?
        return failure_result("CSVが空です!ファイルを確認してください。")
      end

      # === 基本情報（１回だけ取得すればよいもの） ===
      first_row = rows.first #最初のデータ行を取得する
      date_str = first_row["日付"].to_s.strip #日付を文字列として取得し、前後の空白を削除する
      employee_code = first_row["従業員コード"].to_s.strip
      course_name = first_row["コース"].to_s.strip

      #日付文字列をDateオブジェクトに変換する。変換できない場合はnilを返す
      date = Date.parse(date_str) rescue nil
      if date.nil?
        return failure_result("日付が不正です。")
      end
      #従業員コードに対応する従業員をデータベースから検索する
      employee = Employee.find_by(employee_no: employee_code)
      if employee.nil?
        return failure_result("従業員コードが見つかりません!コードを確認してください。")
      end
      #コース名に対応する配達ルートをデータベースから検索する
      delivery_route = DeliveryRoute.find_by(name: course_name)
      if delivery_route.nil?
        return failure_result("コースが見つかりません!コース名を確認してください。")
      end
      #開始時刻を文字列からTimeオブジェクトに変換する。変換できない場合はnilを返す
      started_at = build_time(date, first_row["開始時刻"].to_s.strip)
      if started_at.nil?
        return failure_result("開始時刻が不正です!時刻を確認してください。")
      end
      #開始指針を文字列から数値に変換する。変換できない場合はnilを返す
      odo_start_km = parse_int(first_row["開始指針"].to_s.strip)
      if odo_start_km.nil?
        return failure_result("開始指針が不正です!数値を確認してください。")
      end
      #終了指針を文字列から数値に変換する。変換できない場合はnilを返す
      odo_end_km = parse_int(first_row["終了指針"].to_s.strip)
      if odo_end_km.nil?
        return failure_result("終了指針が不正です!数値を確認してください。")
      end


      # === 各行チェック　DB保存前のバリデーションチェック ===
      rows.each_with_index do |row, index| #CSVの各行をインデックスとともに処理する
        line_number = index + 2 #CSVの行番号（ヘッダー行を考慮して2から始まる）

        if row["開始指針"].present?
          value = parse_int(row["開始指針"])

          if value.nil? || value != odo_start_km
            return failure_result("#{line_number}行目の開始指針が1行目の開始指針と一致しません!数値を確認してください。")
          end
        end
        if row["終了指針"].present?
          value = parse_int(row["終了指針"])

          if value.nil? || value != odo_end_km
            return failure_result("#{line_number}行目の終了指針が1行目の終了指針と一致しません!数値を確認してください。")
          end
        end

        #配達先を文字列として取得し、前後の空白を削除する
        destination = Destination.find_by(name: row["配達先"].to_s.strip)
        if destination.nil?
          return failure_result("#{line_number}行目の配達先が見つかりません!配達先名を確認してください。")
        end
        #件数を文字列から数値に変換する。変換できない場合はnilを返す
        packages_count = parse_int(row["件数"].to_s.strip)
        if packages_count.nil?
          return failure_result("#{line_number}行目の件数が不正です!数値を確認してください。")
        end
        #個数を文字列から数値に変換する。変換できない場合はnilを返す
        pieces_count = parse_int(row["個数"].to_s.strip)
        if pieces_count.nil?
          return failure_result("#{line_number}行目の個数が不正です!数値を確認してください。")
        end
        #完了時間を文字列からTimeオブジェクトに変換する。変換できない場合はnilを返す
        begin
          completed_at = build_time(date, row["完了時間"].to_s.strip)
        rescue ArgumentError
          return failure_result("#{line_number}行目の完了時間が不正です!時刻を確認してください。")
        end
      end
      # === Validationチェックが全て通った後に、データ保存の処理を行う ===
      # === データ保存 ===
      ActiveRecord::Base.transaction do
        # TODO: 将来的にAM/PM分割を考慮し、Runの一意キーにstarted_atを含める設計検討
        #DBを検索。なければ新しいDailyCourseRunオブジェクトを作成する
        daily_course_run = DailyCourseRun.find_or_initialize_by(
          service_date: date,
          delivery_route: delivery_route
        )
        #DailyCourseRunオブジェクトに属性を設定する
        daily_course_run.assign_attributes(
          employee: employee,
          started_at: started_at,
          odo_start_km: odo_start_km,
          odo_end_km: odo_end_km,
        )
        daily_course_run.save!

        #既存のDailyCourseRunStopを全て削除する（同CSV投下時、DB作成し直しのため）
        daily_course_run.daily_course_run_stops.destroy_all

        rows.each do |row|
          destination = Destination.find_by(name: row["配達先"].to_s.strip)

          DailyCourseRunStop.create!(
            daily_course_run: daily_course_run,
            destination: destination,
            packages_count: parse_int(row["件数"].to_s.strip),
            pieces_count: parse_int(row["個数"].to_s.strip),
            completed_at: build_time(date, row["完了時間"].to_s.strip)
          )
        end
      end
      # === データ保存ここまで ===
      import.success!
      # === データ保存が全て成功した後に、成功のメッセージを返す ===
      success_result("CSVのインポートが成功しました!#{rows.size}件のデータがインポートされました。")
    # === 例外処理 ===
    rescue => e
      import&.failed! #インポートのステータスを失敗に更新する
      import&.update(error_message: e.message) #エラーメッセージを保存する

      Rails.logger.error "[DailyCsvImporter] #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      failure_result("CSVのインポート中にエラーが発生しました")
    end
  end

  private

  def sha256(file)
    io = file.tempfile
    io.rewind
    Digest::SHA256.hexdigest(io.read)
  ensure
    io.rewind
  end

  def success_result(message)
    { success: true, message: message }
  end

  def failure_result(message)
    { success: false, message: message }
  end

  # UTF-8エンコードでファイルの内容を読み込む
  def read_as_utf8(file)
    raw = File.binread(file.path)

    raw = raw.byteslice(3..) if raw.bytes[0, 3] == [ 0xEF, 0xBB, 0xBF ] # UTF-8 BOMを削除

    begin
      raw.force_encoding("UTF-8").encode("UTF-8") # UTF-8に変換できない文字は例外になる
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      raw.force_encoding("Windows-31J").encode("UTF-8", invalid: :replace, undef: :replace, replace: "") # Shift_JISをUTF-8に変換できない文字は空文字に置き換える
    end
  end
  # タイムゾーン設定
  def build_time(date, hhmm)
    return nil if hhmm.blank?

    Time.use_zone("Asia/Tokyo") do
      Time.zone.parse("#{date} #{hhmm}")
    end
  rescue
    nil
  end

  # 整数を整えるところ
  def parse_int(value)
    return nil if value.blank?

    cleaned = value.to_s.strip
    cleaned = cleaned.tr("０-９", "0-9") #全角数字を半角に変換
    cleaned = cleaned.tr("、", ",") #カンマを半角に変換
    cleaned = cleaned.delete(",") #カンマを削除

    return nil unless cleaned.match?(/\A\d+\z/) #数字以外が含まれていないか確認

    cleaned.to_i
  end
end
