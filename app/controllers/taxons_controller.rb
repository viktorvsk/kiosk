class TaxonsController < CatalogController
  def show
    @taxon = Catalog::Taxon.includes(:image).eager_load(category: [:products]).find(params[:id])
  end
end
