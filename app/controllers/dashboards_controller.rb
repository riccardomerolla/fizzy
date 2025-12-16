class DashboardsController < ApplicationController
  include FilterScoped
  def show
    @sites = Current.account.sites.alphabetically
    @selected_site = Current.account.sites.find(params[:site_id]) if params[:site_id].present?

    # Parse date range
    @start_date = parse_date(params[:start_date]) || Time.zone.now.beginning_of_month
    @end_date = parse_date(params[:end_date]) || Time.zone.now.end_of_day

    # Fetch KPIs
    kpis_query = Dashboards::KpisQuery.new(
      account: Current.account,
      site: @selected_site,
      start_date: @start_date,
      end_date: @end_date
    )
    @kpis = kpis_query.call

    # Fetch non-conformity breakdown
    nc_query = Dashboards::NonConformityBreakdownQuery.new(
      account: Current.account,
      site: @selected_site,
      start_date: @start_date,
      end_date: @end_date
    )
    @non_conformity_breakdown = nc_query.call
    @pareto_data = nc_query.pareto_data
  end

  private
    def parse_date(date_string)
      return nil if date_string.blank?

      Date.parse(date_string).in_time_zone
    rescue ArgumentError
      nil
    end
end
