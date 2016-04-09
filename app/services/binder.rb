class Binder
  @queue = :common

  def self.perform
    Binder.new.bind!
  end

  def initialize
    @vendor_products = {}
    @products = {}
    @update_sql = ''
    @to_touch = []
  end

  def bind!
    Vendor::Product.select(:id, :info).where(product: nil).where("info->>'model' != '' AND (info->'model')::json IS NOT NULL").find_each(batch_size: 1000) do |vp|
      normalized = vp.model.gsub(/[^\w]/, '').gsub(/\s+/, '').mb_chars.downcase.to_s.freeze
      next if normalized.size == 0
      if @vendor_products[normalized]
        @vendor_products[normalized] << vp.id
      else
        @vendor_products[normalized] = [vp.id]
      end
    end
    Catalog::Product.select(:model, :id).where.not(model: [nil, '']).find_each(batch_size: 1000) do |p|
      normalized = p.model.gsub(/[^\w]/, '').gsub(/\s+/, '').mb_chars.downcase.to_s.freeze
      next if normalized.size == 0
      @products[normalized] = p.id
    end

    compose_update_sql
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(@update_sql)
      Vendor::Product.where(id: @to_touch.flatten.uniq).update_all(updated_at: Time.now)
      Catalog::Product.recount
    end
  end

  private

    def compose_update_sql
      existing_models = @products.keys
      similars = existing_models & @vendor_products.keys
      differents = existing_models - similars
      differents.each do |model|
        @products.delete(model)
        @vendor_products.delete(model)
      end
      @vendor_products.each do |model, ids|
        @to_touch << ids
        if product_id = @products[model]
          @update_sql << "UPDATE vendor_products SET catalog_product_id = #{product_id} WHERE id IN (#{ids.join(',')});\n"
        end
      end
    end
end
