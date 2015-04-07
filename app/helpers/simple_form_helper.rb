module SimpleFormHelper

  def field_for(f, attr_name, attr_type = :text_field, opts = {})
    if opts[:class]
      opts[:class] << ' form-control'
    else
      opts[:class] = 'form-control'
    end
    css_class = f.object.errors[attr_name].any? ? 'form-group has-error' : 'form-group'
    content_tag(:div, class: css_class) do
      f.label(attr_name) +
      f.send(attr_type, attr_name, opts)
    end
  end

  def select_field_for(f, attr_name, collection, opts = {}, html = {})
    if html[:class]
      html[:class] << ' form-control'
    else
      html[:class] = 'form-control'
    end
    opts[:selected] = f.object.try(:send, attr_name)
    html[:autocomplete] ||= :off
    css_class = f.object.errors[attr_name].any? ? 'form-group has-error' : 'form-group'
    content_tag(:div, class: css_class) do
      f.label(attr_name) +
      f.send(:select, attr_name, options_for_select(collection, f.object.try(attr_name).try(:name)), opts, html)
    end
  end

end
