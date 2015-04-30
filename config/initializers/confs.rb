default_settings = {
  'site_name'             => 'Киоск',
  'seo_template_product'  => '{{название}} за {{цена}} грн. в Харькове',
  'txt.js'                => '',
  'txt.css'               => '',
  'ck.logo'               => 'Логотип',
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
