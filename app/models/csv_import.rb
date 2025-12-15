class CsvImport < ApplicationRecord
  STATUSES = %w[pending processing completed failed].freeze

  belongs_to :account
  belongs_to :site

  has_one_attached :file
  has_many :errors, class_name: "CsvImportError", dependent: :destroy

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :original_filename, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :chronologically, -> { order(created_at: :asc) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def success_rate
    return 0 if row_count.zero?
    ((processed_count.to_f / row_count) * 100).round(2)
  end
end
