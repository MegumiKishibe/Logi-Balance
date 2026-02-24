class CsvImport < ApplicationRecord
  enum :status, {
    processing: 0,
    success: 1,
    failed: 2
  }
end
