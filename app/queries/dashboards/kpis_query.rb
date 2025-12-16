class Dashboards::KpisQuery
  attr_reader :account, :site, :start_date, :end_date

  def initialize(account:, site: nil, start_date: nil, end_date: nil)
    @account = account
    @site = site
    @start_date = start_date || Time.zone.now.beginning_of_month
    @end_date = end_date || Time.zone.now.end_of_day
  end

  def call
    {
      volume: volume_kpi,
      quality: quality_kpi,
      turnaround: turnaround_kpi,
      sla: sla_kpi
    }
  end

  private
    def base_scope
      scope = account.reprocessing_cycles.where(received_at: start_date..end_date)
      scope = scope.where(site: site) if site.present?
      scope
    end

    def volume_kpi
      {
        total: base_scope.count,
        conform: base_scope.conform.count,
        nonconform: base_scope.nonconform.count
      }
    end

    def quality_kpi
      total = base_scope.count
      nonconform = base_scope.nonconform.count
      
      {
        nonconform_count: nonconform,
        nonconform_percentage: total.zero? ? 0.0 : (nonconform.to_f / total * 100).round(2)
      }
    end

    def turnaround_kpi
      cycles = base_scope.where.not(sterilized_at: nil)
      
      turnaround_hours = cycles.map(&:turnaround_hours).compact
      
      if turnaround_hours.any?
        sorted = turnaround_hours.sort
        median_index = sorted.size / 2
        p90_index = (sorted.size * 0.9).to_i
        
        {
          median_hours: sorted[median_index],
          p90_hours: sorted[p90_index],
          average_hours: (turnaround_hours.sum / turnaround_hours.size).round(2),
          count: turnaround_hours.size
        }
      else
        {
          median_hours: 0,
          p90_hours: 0,
          average_hours: 0,
          count: 0
        }
      end
    end

    def sla_kpi
      # For SLA, we need to check if site has a contract with SLA defined
      contract = if site.present?
        site.contracts.where.not(sla_turnaround_hours: nil).first ||
          account.contracts.where(site_id: nil).where.not(sla_turnaround_hours: nil).first
      else
        account.contracts.where(site_id: nil).where.not(sla_turnaround_hours: nil).first
      end

      if contract&.sla_turnaround_hours.present?
        sla_hours = contract.sla_turnaround_hours
        cycles = base_scope.where.not(sterilized_at: nil)
        breaches = cycles.select { |c| c.sla_breached?(sla_hours) }
        
        {
          sla_hours: sla_hours,
          total_cycles: cycles.count,
          breach_count: breaches.count,
          breach_percentage: cycles.count.zero? ? 0.0 : (breaches.count.to_f / cycles.count * 100).round(2)
        }
      else
        {
          sla_hours: nil,
          total_cycles: 0,
          breach_count: 0,
          breach_percentage: 0
        }
      end
    end
end
