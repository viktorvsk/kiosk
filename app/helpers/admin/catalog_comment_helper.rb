module Admin::CatalogCommentHelper
  def comments
    @comment ||= Catalog::Comment.all
  end
end
