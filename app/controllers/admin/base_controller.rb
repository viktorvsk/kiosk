class Admin::BaseController < ApplicationController
  check_authorization
  before_action :authenticate_user!
  layout 'admin'

  def dashboard
    render 'admin/dashboard'
    authorize! :manage, :everything
  end

  def internal
    case params[:action]
    when 'binder'
      Resque.enqueue(Binder)
    when 'sitemap'
      Resque.enqueue(SitemapGenerator)
    when 'pricelist_auto'
      Resque.enqueue(PricelistImportAuto)
    when 'pricelist_ym'
      PricelistExport.new("ym").async_generate!
    when 'pricelist_pn'
      PricelistExport.new("pn").async_generate!
    when 'clear_cache'
      Rails.cache.clear
    end
    redirect_to :back, flash: { notice: 'Задача поставлена в очередь' }
    authorize! :manage, :everything
  end

  private

    def check_content_manager_permissions
      authorize! :manage, :content
    end

    def check_admin_permissions
      authorize! :manage, :everything
    end

end
