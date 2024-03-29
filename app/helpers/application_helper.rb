module ApplicationHelper
  def meta(meta_name)
    content_for?(meta_name) ? yield(meta_name) : instance_variable_get("@meta_#{meta_name}")
  end

  def conf_type(conf)
    return :text_area if conf.var =~ /^txt\./
    return :cktext_area if conf.var =~ /^ck\./
    :text_field
  end

  def td(name, value)
    content_tag(:tr) do
      content_tag(:td) { name } + content_tag(:td, class: 'text-center'){ value.to_s }
    end
  end

  def presents(object, klass = nil)
    klass ||= "#{object.class}Presenter"
    klass.constantize.new(object)
  end
end
