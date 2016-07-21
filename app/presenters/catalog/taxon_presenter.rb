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

  def seo_meta_descr(template = Conf['seo_descr_taxon'])
    if seo && seo.description.present?
      seo.description
    else
      seo_mapper = {
        'название' => name,
      }
      seo_regexp = /\{\{(#{seo_mapper.keys.join('|')})\}\}/

      template.gsub(seo_regexp){ seo_mapper[$1] }
    end
  end
end
