class ReprocessingCyclesController < ApplicationController
  def index
    @cycles = Current.account.reprocessing_cycles
      .includes(:site, :set_catalog, :non_conformities)
      .reverse_chronologically

    # Apply filters
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @cycles = @cycles.left_joins(:site, :set_catalog).where(
        "reprocessing_cycles.cycle_barcode LIKE ? OR sites.name LIKE ? OR set_catalogs.name LIKE ?",
        search_term, search_term, search_term
      )
    end

    @cycles = @cycles.where(site_id: params[:site_id]) if params[:site_id].present?
    @cycles = @cycles.where(status: params[:status]) if params[:status].present?

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @cycles = @cycles.where(received_at: start_date..end_date)
    end

    respond_to do |format|
      format.html { @cycles = @cycles }
      format.csv { send_csv_export }
    end
  end

  def show
    @cycle = Current.account.reprocessing_cycles
      .includes(:site, :set_catalog, :non_conformities)
      .find(params[:id])
  end

  private
    def send_csv_export
      require "csv"
      
      csv_data = CSV.generate(headers: true) do |csv|
        csv << [
          "Cycle Barcode", "Site", "Set Catalog", "Status",
          "Received At", "Washed At", "Packed At", "Sterilized At", "Delivered At",
          "Turnaround Hours", "Non-Conformities"
        ]
        
        @cycles.each do |cycle|
          csv << [
            cycle.cycle_barcode,
            cycle.site.name,
            cycle.set_catalog.name,
            cycle.status,
            cycle.received_at,
            cycle.washed_at,
            cycle.packed_at,
            cycle.sterilized_at,
            cycle.delivered_at,
            cycle.turnaround_hours,
            cycle.non_conformities.map { |nc| "#{nc.kind}: #{nc.notes}" }.join("; ")
          ]
        end
      end
      
      send_data csv_data, filename: "reprocessing_cycles_#{Time.zone.now.to_i}.csv", type: "text/csv"
    end
end
