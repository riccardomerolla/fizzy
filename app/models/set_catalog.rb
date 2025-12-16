class SetCatalog < ApplicationRecord
  belongs_to :account

  has_many :reprocessing_cycles, dependent: :restrict_with_error

  validates :catalog_barcode, presence: true, uniqueness: { scope: :account_id }
  validates :name, presence: true

  scope :alphabetically, -> { order(:name) }
  scope :by_family, ->(family) { where(family: family) if family.present? }
end
