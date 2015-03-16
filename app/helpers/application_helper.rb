module ApplicationHelper
  def admin_nav_skeleton
    {
      'CRM' => {
        'Заказы'      => '',
        'Клиенты'     => '',
        'Комментарии' => '',
        'Коллбэки'    => '',
      },
      'Каталог' => {
        'Товары'          => '',
        'Категории'       => '',
        'Фильтры'         => '',
        'Характеристики'  => '',
        'Бренды'          => ''
      },
      'Поставщики' => {
        'Прайсы' => admin_vendor_merchants_path,
        'Товары' => ''
      },
      'Настройка' => {
        'Страницы'  => '',
        'Блоки'     => '',
        'Слайды'    => '',
      }
    }
  end

  def admin_nav
    li_tags = admin_nav_skeleton.map do |k, v|
      links = v.map do |link_name, link_url|
        content_tag(:li, class: 'list-group-item'){ link_to(link_name, link_url) }
      end.join("\n").html_safe

      content_tag(:li, class: 'list-group-item active'){ k } + links
    end.join("\n").html_safe

    content_tag :ul, class: 'list-group admin-nav' do
      li_tags
    end
  end

end
