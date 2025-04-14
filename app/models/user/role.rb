module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, %i[ admin member system ].index_by(&:itself), scopes: false

    scope :member, -> { where(role: :member) }
    scope :without_system, -> { where.not(role: :system) }
    scope :active, -> { without_system.where(active: true) }
  end

  class_methods do
    def system
      find_or_create_by!(role: :system) { it.name = "System" }
    end
  end

  def can_administer?(other)
    admin? && other != self
  end
end
