module ActivePricelist
  class Dynamic < ActivePricelist::Base
    def initialize(opts = {})
      super
      @callback = opts['callback']
    end
    private
    def transform
      -> do
        $SAFE = 2
        eval(@callback)
      end
    end
  end
end
