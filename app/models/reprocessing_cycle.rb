class ReprocessingCycle < ApplicationRecord
  belongs_to :account
  belongs_to :site
  belongs_to :set_catalog

  has_many :non_conformities, dependent: :destroy

  validates :cycle_barcode, presence: true, uniqueness: { scope: [ :account_id, :site_id ] }
  validates :received_at, presence: true
  validates :status, presence: true, inclusion: { in: %w[conform nonconform] }
  validates :source, presence: true

  scope :conform, -> { where(status: "conform") }
  scope :nonconform, -> { where(status: "nonconform") }
  scope :in_date_range, ->(start_date, end_date) do
    where(received_at: start_date..end_date) if start_date.present? && end_date.present?
  end
  scope :for_site, ->(site_id) { where(site_id: site_id) if site_id.present? }
  scope :chronologically, -> { order(received_at: :asc) }
  scope :reverse_chronologically, -> { order(received_at: :desc) }

  def turnaround_hours
    if sterilized_at.present? && received_at.present?
      ((sterilized_at - received_at) / 1.hour).round(2)
    end
  end

  def sla_breached?(sla_hours)
    return false if sla_hours.blank? || turnaround_hours.blank?
    turnaround_hours > sla_hours
  end

  def conform?
    status == "conform"
  end

  def nonconform?
    status == "nonconform"
  end
end
