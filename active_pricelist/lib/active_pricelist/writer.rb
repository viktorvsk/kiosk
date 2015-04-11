# ActivePriceList::Writer is responsible for outputting
# XML if XSLT template given.
# After products hash gets calculated, it transforms to
# XML and XSLT template is applied.
module ActivePricelist
  class Writer
    class << self
      def transform(products, xslt)
        xml       = products.to_xml
        doc       = Nokogiri::XML(xml)
        template  = Nokogiri::XSLT(xslt)
        template.transform(doc)
      end
    end
  end
end
