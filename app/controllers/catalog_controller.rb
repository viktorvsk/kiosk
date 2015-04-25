class CatalogController < ApplicationController
  before_action :set_menu_taxons

  private

  def set_menu_taxons
    @taxons = Catalog::Taxon.eager_load(:category)
  end

end
