default_settings = {
  'site_name'             => 'Киоск',
  'delta'                 => '0.2',
  'similar_distance'      => '0.15',
  'marketplaces'          => 'rozetka hotline brain erc yugcontract',
  'default_title'         => 'evoTex',
  'kiosk_meta_title'      => 'Киоск',
  'kiosk_meta_description'=> 'Интернет-магазин',
  'kiosk_meta_keywords'   => 'Ноутбуки, нетбуки в Харькове',
  'seo_template_product'  => '{{название}} за {{цена}} грн. в Харькове',
  'seo_template_category' => '{{имя-мн}} в Харькове. Купить {{имя-ед}}',
  'txt.js'                => '',
  'txt.robots'            => '',
  'txt.css'               => '',
  'txt.delivery_types'    => '',
  'txt.payment_types'     => '',
  'new_layout_limit'      => '100',
  'ck.logo'               => 'Логотип',
  'ck.logo_min'           => '<img align="top" alt="" src="http://evotex.kh.ua/logo_min.png" style="width: 60px; height: 20px; display: inline; padding: 0; margin: 0" />',
  'ck.delivery_card'      => 'Оплата\Доставка в карточке товара',
  'ck.social_card'        => 'Кнопки соцсетей (карточка товара)',
  'ck.social_footer'      => 'Кнопки соцсетей (футер)',
  'ck.footer1'            => '1',
  'ck.footer2'            => '2',
  'ck.footer3'            => '3',
  'ck.vk_group'           => '3',
  'ck.phones'             => '+380931234567',
  'ck.phones_and_mode'    => 'выходные',
  'ck.homepage_seo'       => 'Интернет-магазин ...',
  'ck.mode'               => '<h1>Режим работы</h1>',
  'ck.mode_product_card'  => '<h1>Режим работы</h1> Карточка товара',
  'b.search_with_similars'=> 't',
  'n.new_layout_sessions' => '0'
}

if Conf.table_exists?
  default_settings.each do |k, v|
    Conf[k] = v if Conf.get_all[k].nil?
  end
end
