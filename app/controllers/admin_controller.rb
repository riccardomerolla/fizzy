class AdminController < ApplicationController
  before_action :ensure_is_staff_member
end
