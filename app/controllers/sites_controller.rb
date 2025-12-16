class SitesController < ApplicationController
  before_action :set_site, only: [ :show, :edit, :update, :destroy ]

  def index
    @sites = Current.account.sites.alphabetically
  end

  def show
  end

  def new
    @site = Current.account.sites.build(timezone: "Europe/Rome")
  end

  def create
    @site = Current.account.sites.build(site_params)
    
    if @site.save
      redirect_to sites_path, notice: "Site was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @site.update(site_params)
      redirect_to sites_path, notice: "Site was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @site.destroy
    redirect_to sites_path, notice: "Site was successfully deleted."
  end

  private
    def set_site
      @site = Current.account.sites.find(params[:id])
    end

    def site_params
      params.require(:site).permit(:name, :code, :timezone)
    end
end
