class JsonValidator < ActiveModel::EachValidator

  def initialize(options)
    options.reverse_merge!(:message => :invalid)
    super(options)
  end

  def validate_each(record, attribute, value)
    value = value.strip if value.is_a?(String)
    JSON.parse(value)
  rescue JSON::ParserError => exception
    record.errors.add(attribute, options[:message], exception_message: exception.message)
  end

end
