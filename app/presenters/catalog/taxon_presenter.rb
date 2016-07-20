class Catalog::TaxonPresenter < SimpleDelegator
  def seo_meta_title(template = Conf['seo_template_taxon'])
    if seo && seo.title.present?
      seo.title
    else
      seo_mapper = {
        'имя' => name,
      }
      seo_regexp = /\{\{(#{seo_mapper.keys.join('|')})\}\}/

      template.gsub(seo_regexp){ seo_mapper[$1] }
    end
  end
end
