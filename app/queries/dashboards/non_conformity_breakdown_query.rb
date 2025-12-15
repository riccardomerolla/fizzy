class Dashboards::NonConformityBreakdownQuery
  attr_reader :account, :site, :start_date, :end_date

  def initialize(account:, site: nil, start_date: nil, end_date: nil)
    @account = account
    @site = site
    @start_date = start_date || Time.zone.now.beginning_of_month
    @end_date = end_date || Time.zone.now.end_of_day
  end

  def call
    non_conformities = base_scope
    
    {
      by_kind: breakdown_by_kind(non_conformities),
      total: non_conformities.count
    }
  end

  def pareto_data
    breakdown_by_kind(base_scope).sort_by { |k, v| -v[:count] }.first(5)
  end

  private
    def base_scope
      scope = account.non_conformities.where(occurred_at: start_date..end_date)
      
      if site.present?
        cycle_ids = account.reprocessing_cycles.where(site: site).pluck(:id)
        scope = scope.where(reprocessing_cycle_id: cycle_ids)
      end
      
      scope
    end

    def breakdown_by_kind(non_conformities)
      non_conformities.group(:kind).count.transform_values do |count|
        {
          count: count,
          percentage: (count.to_f / non_conformities.count * 100).round(2)
        }
      end
    end
end
