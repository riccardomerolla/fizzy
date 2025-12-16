class Contract < ApplicationRecord
  belongs_to :account
  belongs_to :site, optional: true

  has_many :invoice_periods, dependent: :destroy

  validates :name, presence: true
  validates :price_per_set_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :penalty_per_breach_cents, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :sla_turnaround_hours, numericality: { greater_than: 0, allow_nil: true }

  def price_per_set
    Money.new(price_per_set_cents, "EUR") if defined?(Money)
  end

  def penalty_per_breach
    Money.new(penalty_per_breach_cents, "EUR") if penalty_per_breach_cents.present? && defined?(Money)
  end

  def default_contract?
    site_id.nil?
  end
end
