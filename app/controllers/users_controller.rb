class UsersController < ApplicationController
  require_unauthenticated_access only: %i[ new create ]

  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :set_account_from_join_code, only: %i[ new create ]
  before_action :ensure_permission_to_administer_user, only:  %i[ update destroy ]

  def index
    @users = User.active
  end

  def new
    @user = User.new
  end

  def create
    user = User.create!(user_params)
    start_new_session_for user
    redirect_to root_path
  end

  def show
  end

  def edit
  end

  def update
    @user.update! user_params
    redirect_to @user
  end

  def destroy
    @user.deactivate
    redirect_to users_path
  end

  private
    def set_account_from_join_code
      @account = Account.find_by_join_code!(params[:join_code])
    end

    def set_user
      @user = User.active.find(params[:id])
    end

    def ensure_permission_to_administer_user
      head :forbidden unless Current.user.can_administer?(@user)
    end

    def user_params
      params.expect(user: [ :name, :email_address, :password, :avatar ])
    end
end
