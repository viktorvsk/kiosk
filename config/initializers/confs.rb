default_settings = {
  'site_name'             => 'Киоск',
  'delta'                 => '0.2',
  'seo_template_product'  => '{{название}} за {{цена}} грн. в Харькове',
  'txt.js'                => '',
  'txt.css'               => '',
  'txt.delivery_types'    => '',
  'txt.payment_types'     => '',
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
  'ck.mode'               => '<h1>Режим работы</h1>'
}

default_settings.each do |k, v|
  Conf[k] = v if Conf.get_all[k].blank?
end
