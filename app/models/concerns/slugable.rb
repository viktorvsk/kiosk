module Slugable
  def self.included(base)
    base.class_eval do

      def slug
        self[:slug].presence || Russian.translit(name).parameterize
      end

    end
  end
end
