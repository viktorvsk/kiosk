class TaxonsController < CatalogController
  def show
    @taxon = Catalog::Taxon.includes(category: :products).find(params[:id])
    if params[:slug] != @taxon.slug
      redirect_to t_path(slug: @taxon.slug, id: @taxon), status: 301
    end
  end
end
