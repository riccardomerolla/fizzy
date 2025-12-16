class InvoicePeriods::Compute
  attr_reader :contract, :year, :month

  def initialize(contract:, year:, month:)
    @contract = contract
    @year = year
    @month = month
  end

  def call
    invoice_period = find_or_initialize_invoice_period
    
    # Compute values
    cycles = reprocessing_cycles_for_period
    
    invoice_period.assign_attributes(
      processed_count: cycles.count,
      nonconform_count: cycles.nonconform.count,
      billable_count: compute_billable_count(cycles),
      sla_breach_count: compute_sla_breach_count(cycles),
      subtotal_cents: compute_subtotal(cycles),
      penalties_cents: compute_penalties(cycles),
      computed_at: Time.current
    )
    
    invoice_period.total_cents = invoice_period.subtotal_cents - invoice_period.penalties_cents
    
    invoice_period.save!
    invoice_period
  end

  private
    def find_or_initialize_invoice_period
      contract.invoice_periods.find_or_initialize_by(year: year, month: month) do |ip|
        ip.account = contract.account
      end
    end

    def reprocessing_cycles_for_period
      start_date = Date.new(year, month, 1).beginning_of_month
      end_date = start_date.end_of_month
      
      scope = contract.account.reprocessing_cycles.where(sterilized_at: start_date..end_date)
      scope = scope.where(site: contract.site) if contract.site.present?
      scope
    end

    def compute_billable_count(cycles)
      if contract.exclude_nonconform
        cycles.conform.count
      else
        cycles.count
      end
    end

    def compute_sla_breach_count(cycles)
      return 0 unless contract.sla_turnaround_hours.present?
      
      cycles.select { |c| c.sla_breached?(contract.sla_turnaround_hours) }.count
    end

    def compute_subtotal(cycles)
      compute_billable_count(cycles) * contract.price_per_set_cents
    end

    def compute_penalties(cycles)
      return 0 unless contract.penalty_per_breach_cents.present?
      
      compute_sla_breach_count(cycles) * contract.penalty_per_breach_cents
    end
end
