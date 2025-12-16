class NonConformity < ApplicationRecord
  KINDS = %w[missing_item failed_wash packaging_error sterilization_fail other].freeze

  belongs_to :account
  belongs_to :reprocessing_cycle

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :occurred_at, presence: true

  scope :by_kind, ->(kind) { where(kind: kind) if kind.present? }
  scope :in_date_range, ->(start_date, end_date) do
    where(occurred_at: start_date..end_date) if start_date.present? && end_date.present?
  end
  scope :chronologically, -> { order(occurred_at: :asc) }
  scope :reverse_chronologically, -> { order(occurred_at: :desc) }

  def self.pareto_summary
    group(:kind).count.sort_by { |_k, v| -v }
  end
end
