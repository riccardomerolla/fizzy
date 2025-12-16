class ContractsController < ApplicationController
  before_action :set_contract, only: [ :show, :edit, :update, :destroy ]

  def index
    @contracts = Current.account.contracts.includes(:site).order(created_at: :desc)
  end

  def show
  end

  def new
    @contract = Current.account.contracts.build
  end

  def create
    @contract = Current.account.contracts.build(contract_params)
    
    if @contract.save
      redirect_to contracts_path, notice: "Contract was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @contract.update(contract_params)
      redirect_to contracts_path, notice: "Contract was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contract.destroy
    redirect_to contracts_path, notice: "Contract was successfully deleted."
  end

  private
    def set_contract
      @contract = Current.account.contracts.find(params[:id])
    end

    def contract_params
      params.require(:contract).permit(
        :name, :site_id, :price_per_set_cents, :exclude_nonconform,
        :sla_turnaround_hours, :penalty_per_breach_cents
      )
    end
end
