class InvoicePeriod < ApplicationRecord
  belongs_to :account
  belongs_to :contract

  validates :year, presence: true, numericality: { only_integer: true }
  validates :month, presence: true, numericality: { only_integer: true, in: 1..12 }
  validates :year, uniqueness: { scope: [ :account_id, :contract_id, :month ] }

  scope :for_year, ->(year) { where(year: year) if year.present? }
  scope :for_month, ->(month) { where(month: month) if month.present? }
  scope :chronologically, -> { order(year: :asc, month: :asc) }
  scope :reverse_chronologically, -> { order(year: :desc, month: :desc) }

  def period_label
    Date.new(year, month, 1).strftime("%B %Y")
  end

  def computed?
    computed_at.present?
  end

  def total
    Money.new(total_cents, "EUR") if defined?(Money)
  end

  def subtotal
    Money.new(subtotal_cents, "EUR") if defined?(Money)
  end

  def penalties
    Money.new(penalties_cents, "EUR") if defined?(Money)
  end
end
