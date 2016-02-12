module Admin::MarkupsHelper
  def markup_links
    {'active': 'Активные', 'pages': 'Страницы', 'articles': 'Статьи', 'helps': 'Страницы помощи', 'slides': 'Слайды'}
  end

  def markup_types
    Markup::TYPES.map{ |m| [t("activerecord.attributes.markup.types.#{m}"), m] }
  end
end
