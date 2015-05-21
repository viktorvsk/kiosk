module Slugable
  def self.included(base)
    base.class_eval do

      def slug
        text = self[:slug].presence || name.to_s
        Russian.translit(text).parameterize
      end

    end
  end
end
