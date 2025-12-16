class InvoicePeriodsController < ApplicationController
  def index
    @contract = Current.account.contracts.find(params[:contract_id])
    @invoice_periods = @contract.invoice_periods.reverse_chronologically
  end

  def show
    @invoice_period = Current.account.invoice_periods
      .includes(:contract)
      .find(params[:id])
  end

  def new
    @contract = Current.account.contracts.find(params[:contract_id])
    @invoice_period = @contract.invoice_periods.build(
      year: Time.zone.now.year,
      month: Time.zone.now.month
    )
  end

  def create
    @contract = Current.account.contracts.find(params[:contract_id])
    @invoice_period = @contract.invoice_periods.build(invoice_period_params)
    @invoice_period.account = Current.account
    
    # Compute the invoice
    service = InvoicePeriods::Compute.new(
      contract: @contract,
      year: @invoice_period.year,
      month: @invoice_period.month
    )
    
    @invoice_period = service.call
    
    redirect_to invoice_period_path(@invoice_period), notice: "Invoice computed successfully."
  rescue ActiveRecord::RecordInvalid => e
    @invoice_period.errors.add(:base, e.message)
    render :new, status: :unprocessable_entity
  end

  def recompute
    @invoice_period = Current.account.invoice_periods.find(params[:id])
    
    service = InvoicePeriods::Compute.new(
      contract: @invoice_period.contract,
      year: @invoice_period.year,
      month: @invoice_period.month
    )
    
    service.call
    
    redirect_to invoice_period_path(@invoice_period), notice: "Invoice recomputed successfully."
  end

  private
    def invoice_period_params
      params.require(:invoice_period).permit(:year, :month)
    end
end
