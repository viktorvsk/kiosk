class TaxonsController < CatalogController
  def show
    @taxon = Catalog::Taxon.includes(:image).eager_load(category: [:products]).find(params[:id])
    @meta_title = @taxon.name
    # @meta_description = @taxon.name
    # @meta_keywords = @taxon.name
  end
end
