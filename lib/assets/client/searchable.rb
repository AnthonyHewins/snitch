module Searchable
  ARITY_MISMATCH = "arity mismatch for supplied lambda (must accept 1-2 args)"
  private_constant :ARITY_MISMATCH
  
  protected
  def find(collection, opts={}, &block)
    case block&.arity
    when 1
      query = generate_select_syntax opts
      collection.find {|i| block.call(i) && satisfies_query?(i, query)}
    when 2
      filter_by_fields(collection, opts).inject &block
    when NilClass
      query = generate_select_syntax opts
      collection.find {|i| satisfies_query?(i, query)}
    else
      raise ArgumentError, ARITY_MISMATCH
    end
  end

  def filter(collection, opts={}, &block)
    filter_by_proc filter_by_fields(collection, opts), &block
  end

  private
  def filter_by_proc(collection, &block)
    return collection if block.nil?
    case block.arity
    when 1
      collection.select &block
    when 2
      collection.length < 2 ? collection : [collection.inject(&block)]
    else
      raise ArgumentError, ARITY_MISMATCH
    end
  end

  def filter_by_fields(collection, opts={})
    query = generate_select_syntax opts
    collection.select {|element| satisfies_query? element, query}
  end

  def generate_select_syntax(opts)
    return [] if opts.empty?
    fields, desired_values = opts.keys, opts.values
    operators = determine_sensible_operators desired_values

    fields.zip operators, desired_values
  end

  def satisfies_query?(element, query)
    query.all? do |field, operator, required_value|
      element.send(field).send(operator, required_value)
    end
  end
  
  def determine_sensible_operators(values)
    values.map {|value| value.instance_of?(Regexp) ? :match? : :==}
  end
end
