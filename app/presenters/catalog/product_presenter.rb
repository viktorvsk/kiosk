class Catalog::ProductPresenter < SimpleDelegator

  def preview_path
    images.includes(:imageable).sort_by(&:position).first.try(:to_s) || "/product_missing.png"
  end

  def seo_meta_title(template = Conf['seo_template_product'])
    if seo && seo.title.present?
      seo.title
    else
      seo_mapper = {
        'название'              => name,
        'артикул'               => id,
        'главное-имя'           => main_name,
        'цена'                  => price,
        'старая-цена'           => old_price,
        'название-категории'    => category.name,
        'название-категории-1'  => category.s_name.to_s,
        'бренд'                 => brand.try(:name).to_s
      }
      seo_regexp = /\{\{(#{seo_mapper.keys.join('|')})\}\}/

      template.gsub(seo_regexp){ seo_mapper[$1] }
    end
  end

  def seo_meta_descr(template = Conf['seo_descr_product'])
    if seo && seo.description.present?
      seo.description
    else
      seo_mapper = {
        'название'  => name,
        'артикул'   => id
      }
      seo_regexp = /\{\{(#{seo_mapper.keys.join('|')})\}\}/

      template.gsub(seo_regexp){ seo_mapper[$1] }
    end
  end

  def stats
    stats = {
      '<b>Название</b>'       => name,
      '<b>Пустые поля</b>'    => attributes.select{ |k, v| v.blank? }.keys.map{ |k| I18n.t("activerecord.attributes.catalog/product.#{k}") }.join('; '),
      '<b>Характеристик</b>'  => product_properties.where.not(name: nil).count,
      '<b>Фильтров</b>'       => product_filters.where.not(filter_value: nil).count,
      '<b>Изображений</b>'    => images.count,
      '<b>Длина описания</b>' => description.to_s.size
    }
    stats.to_a.map{ |stat| stat.join(": ") }.join("\n<br/>")
  end

  def warranty(warranty_id=nil)
    warranty_id ||= Catalog::Property.warranty.try(:id)
    return unless warranty_id
    product_properties.where("catalog_property_id = :w AND name != '' AND name IS NOT NULL", w: warranty_id).first
  end

  def model
    __getobj__
  end
end
