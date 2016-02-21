module Admin::CatalogCommentHelper
  def comments
    @comment ||= Catalog::Comment.all
  end

  def comment_links
    { 'olds' => 'Обработанные', 'news' => 'Не обработанные' }
  end
end
