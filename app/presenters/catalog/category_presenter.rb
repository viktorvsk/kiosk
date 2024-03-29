class Catalog::CategoryPresenter < SimpleDelegator

  def seo_meta_title(template = Conf['seo_template_category'])
    if seo.present? && seo.title.present?
      seo.title
    else
      seo_mapper = { 'имя-мн' => name, 'имя-ед' => s_name }
      seo_regexp = /\{\{(#{seo_mapper.keys.join('|')})\}\}/
      template.gsub(seo_regexp) { seo_mapper[$1] }
    end
  end

  def seo_meta_descr(template = Conf['seo_descr_category'])
    if seo.present? && seo.description.present?
      seo.description
    else
      seo_mapper = { 'название' => name }
      seo_regexp = /\{\{(#{seo_mapper.keys.join('|')})\}\}/
      template.gsub(seo_regexp) { seo_mapper[$1] }
    end
  end

  def model
    __getobj__
  end

end
