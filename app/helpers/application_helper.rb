module ApplicationHelper
  def meta(meta_name)
    content_for?(meta_name) ? yield(meta_name) : instance_variable_get("@meta_#{meta_name}")
  end

  def conf_type(conf)
    return :text_area if conf.var =~ /^txt\./
    return :cktext_area if conf.var =~ /^ck\./
    :text_field
  end
end
