class CsvImportsController < ApplicationController
  before_action :set_site, only: [ :new, :create ]
  before_action :set_csv_import, only: [ :show ]

  def index
    @csv_imports = Current.account.csv_imports
      .includes(:site)
      .reverse_chronologically
  end

  def show
    @errors = @csv_import.import_errors.chronologically
  end

  def new
    @csv_import = @site.csv_imports.build
  end

  def create
    @csv_import = @site.csv_imports.build(csv_import_params)
    @csv_import.account = Current.account
    
    if @csv_import.save
      CsvImportJob.perform_later(@csv_import)
      redirect_to csv_import_path(@csv_import), notice: "CSV import started. Processing in background..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_site
      @site = Current.account.sites.find(params[:site_id])
    end

    def set_csv_import
      @csv_import = Current.account.csv_imports.find(params[:id])
    end

    def csv_import_params
      params.require(:csv_import).permit(:file).tap do |p|
        if params[:csv_import][:file].present?
          p[:original_filename] = params[:csv_import][:file].original_filename
        end
      end
    end
end
