default_settings = {
  'site_name'             => 'Киоск',
  'delta'                 => '0.2',
  'similar_distance'      => '0.15',
  'marketplaces'          => 'rozetka hotline brain erc yugcontract repka',
  'default_title'         => 'evoTex',
  'kiosk_meta_title'      => 'Киоск',
  'kiosk_meta_description'=> 'Интернет-магазин',
  'kiosk_meta_keywords'   => 'Ноутбуки, нетбуки в Харькове',
  'seo_template_product'  => '{{название}} за {{цена}} грн. в Харькове',
  'seo_template_category' => '{{имя-мн}} в Харькове. Купить {{имя-ед}}',
  'seo_template_taxon'    => '{{имя}} в Харькове. Купить',
  'seo_descr_product'     => '{{название}} + ({{артикул}}) по выгодной цене с доставкой по Украине. Заказывайте {{название}} + ({{артикул}}) прямо сейчас!  ☎(098)118-33-00 ✓отзывы ✓качество ✓гарантия',
  'seo_descr_category'    => '{{название}} + по самым низким ценам с доставкой по всей территории Украины в интернет-магазине Evotex',
  'seo_descr_taxon'       => '{{название}} + по самым низким ценам с доставкой по всей территории Украины в интернет-магазине Evotex',
  'txt.js'                => '',
  'txt.robots'            => '',
  'txt.css'               => '',
  'txt.delivery_types'    => '',
  'txt.words_to_downcase' => '',
  'txt.payment_types'     => '',
  'txt.credit'            => '<img src="http://iforms.rsb.ua/itrade/data/files/img/buttonforward.jpg"/>',
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
  'b.use_go_xlsx'         => 'f',
  'b.search_with_similars'=> 't'
}

if Conf.table_exists?
  default_settings.each do |k, v|
    Conf[k] = v if Conf.get_all[k].nil?
  end
end
