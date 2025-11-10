class JoinCodesController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  before_action :set_join_code
  before_action :ensure_join_code_is_valid

  layout "public"

  def new
    @account = Account.find_by_external_account_id!(tenant)
    @account_name = @account.name
  end

  def create
    Identity.transaction do
      identity = Identity.find_or_create_by!(email_address: params.expect(:email_address))
      identity.memberships.find_or_create_by!(tenant: tenant) do |membership|
        membership.join_code = code
      end
      magic_link = identity.send_magic_link
      flash[:magic_link_code] = magic_link&.code if Rails.env.development?
    end

    session[:return_to_after_authenticating] = landing_url(script_name: "/#{tenant}")
    redirect_to session_magic_link_path
  end

  private
    def ensure_join_code_is_valid
      head :not_found unless @join_code&.active?
    end

    def set_join_code
      # TODO:PLANB: this find should be scoped by account
      @join_code ||= Account::JoinCode.active.find_by(code: code)
    end

    def tenant
      params.expect(:tenant)
    end

    def code
      params.expect(:code)
    end
end
