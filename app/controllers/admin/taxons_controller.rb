class Admin::TaxonsController < Admin::BaseController
  before_action :check_admin_permissions

  def index
    @taxons = Catalog::Taxon.where(ancestry: nil)
  end

  def new
    @taxon = Catalog::Taxon.new
    @taxon.build_seo unless @taxon.seo
  end

  def destroy
    Catalog::Taxon.where(id: params[:id]).destroy_all
    redirect_to :back
  end

  def edit
    @taxon = Catalog::Taxon.find(params[:id])
    @taxon.build_seo unless @taxon.seo
  end

  def create
    @taxon = Catalog::Taxon.new(taxon_params)
    if @taxon.save
      redirect_to admin_taxons_path
    else
      render :edit
    end
      
  end

  def update
    @taxon = Catalog::Taxon.find(params[:id])
    if @taxon.update(taxon_params)
      redirect_to admin_taxons_path
    else
      render :edit
    end
  end

  def sort
    Catalog::Taxon.sort(params[:catalog_taxon])
    render nothing: true
  end

  private

    def taxon_params
      params.require(:catalog_taxon).permit(:name, :slug,
                                            seo_attributes: [:title, :keywords, :description],
                                            image_attributes: [:attachment])
    end

end