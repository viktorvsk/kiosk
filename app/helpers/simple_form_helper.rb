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
      f.send(attr_type, attr_name, opts) +
      f.error(attr_name)
    end
  end

  def select_field_for(f, attr_name, opts = {})
    opts[:input_html] ||= {}
    if opts[:input_html][:class]
      opts[:input_html][:class] << ' form-control'
    else
      opts[:input_html][:class] = 'form-control'
    end
    opts[:selected] = f.object.try(:send, attr_name)
    css_class = f.object.errors[attr_name].any? ? 'form-group has-error' : 'form-group'
    content_tag(:div, class: css_class) do
      f.send(:input, attr_name, opts) +
      f.error(attr_name)
    end
  end

end
