class FirstRunsController < ApplicationController
  allow_unauthenticated_access

  before_action :prevent_repeats

  def show
  end

  def create
    user = FirstRun.create!(params.expect(user: [ :name, :email_address, :password ]))
    start_new_session_for user
    redirect_to root_path
  end

  private
    def prevent_repeats
      redirect_to root_path if Account.any?
    end
end
