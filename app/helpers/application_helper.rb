module ApplicationHelper
  def meta(meta_name)
    content_for?(meta_name) ? yield(meta_name) : instance_variable_get("@meta_#{meta_name}")
  end
end
