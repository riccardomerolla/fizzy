class NonConformitiesController < ApplicationController
  def index
    @non_conformities = Current.account.non_conformities
      .includes(reprocessing_cycle: [ :site, :set_catalog ])
      .reverse_chronologically
    
    # Apply filters
    if params[:site_id].present?
      cycle_ids = Current.account.reprocessing_cycles.where(site_id: params[:site_id]).pluck(:id)
      @non_conformities = @non_conformities.where(reprocessing_cycle_id: cycle_ids)
    end
    
    @non_conformities = @non_conformities.by_kind(params[:kind]) if params[:kind].present?
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @non_conformities = @non_conformities.where(occurred_at: start_date..end_date)
    end
    
    # Pareto analysis
    @pareto_summary = @non_conformities.group(:kind).count.sort_by { |_k, v| -v }
    
    respond_to do |format|
      format.html { @non_conformities = @non_conformities }
      format.csv { send_csv_export }
    end
  end

  private
    def send_csv_export
      require "csv"
      
      csv_data = CSV.generate(headers: true) do |csv|
        csv << [
          "Occurred At", "Kind", "Site", "Cycle Barcode", "Set Catalog",
          "Notes", "Cycle Status"
        ]
        
        @non_conformities.each do |nc|
          cycle = nc.reprocessing_cycle
          csv << [
            nc.occurred_at,
            nc.kind,
            cycle.site.name,
            cycle.cycle_barcode,
            cycle.set_catalog.name,
            nc.notes,
            cycle.status
          ]
        end
      end
      
      send_data csv_data, filename: "non_conformities_#{Time.zone.now.to_i}.csv", type: "text/csv"
    end
end
