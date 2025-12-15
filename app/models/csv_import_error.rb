class CsvImportError < ApplicationRecord
  belongs_to :csv_import

  validates :row_number, presence: true
  validates :message, presence: true

  scope :chronologically, -> { order(row_number: :asc) }
end
