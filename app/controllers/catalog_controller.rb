class CatalogController < ApplicationController
  def static_page
    @page = Markup.pages_and_articles.find(params[:id])
    render 'markups/_page', locals: { page: @page }
  end

  def help_pages
    @pages = Markup.active.helps
    @page = @pages.sample
    render 'markups/helps'
  end

  def show_help_page
    @pages = Markup.active.helps
    @page = Markup.active.helps.find(params[:id])
    render 'markups/helps'
  end

  def help_page
    render 'markups/_page', locals: { page: @page }
  end

end
