class Admin::FiltersController < Admin::BaseController
  before_action :set_filter, only: [:edit, :update, :destroy]

  def index
    @filters = Catalog::Filter.page(params[:page])
  end

  private

  def set_filter
  end

end
