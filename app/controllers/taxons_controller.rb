class TaxonsController < CatalogController
  def show
    @taxon = Catalog::Taxon.includes(category: :products).find(params[:id])
    if params[:slug] != @taxon.slug
      redirect_to t_path(slug: @taxon.slug, id: @taxon), status: 301
    end
    @meta_title = presents(@taxon).seo_meta_title
    @meta_description = presents(@taxon).seo_meta_descr
    @meta_keywords = @taxon.seo.try(:keywords)
  end
end
