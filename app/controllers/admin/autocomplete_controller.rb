class Admin::AutocompleteController < Admin::BaseController
  def properties
    render text: Catalog::Property.ransack(name_cont: params[:term]).result.limit(10).pluck(:name)
  end
end
