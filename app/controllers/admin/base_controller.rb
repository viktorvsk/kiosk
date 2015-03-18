class Admin::BaseController < ApplicationController
  before_action :authenticate_user!, :authorize_admin!
  layout 'admin'
end
