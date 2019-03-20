require 'csv'

class View
  attr_reader :collection

  def initialize(collection)
    case collection
    when ActiveRecord::Relation
      @collection = collection
    when Array
      @collection = typecheck collection
    else
      raise TypeError, "collection must be Array/ActiveRecord::Relation, got #{collection.class}"
    end
  end

  def to_csv(filename, cols=nil)
    CSV.open(filename, 'wb') {|csv| arrayify(cols).each {|array| csv << array}}
  end

  def display(cols=nil)
    arrayify(cols).each do |array|
      array.map(&:to_s).each do |item|
        length = item.length
        if length < 25
          print item + (" " * (25 - length))
        else
          print item[0..20] + "... "
        end
      end
      print "\n"
    end
  end

  private
  def typecheck(collection)
    klass = collection.first.class
    return collection if collection.all? {|item| item.instance_of? klass}
    raise TypeError, "All instances must be of the same class"
  end

  def arrayify(cols=nil)
    return @collection if @collection.instance_of? Array
    cols ||= @collection.model.column_names
    @collection.map {|record| cols.map {|col| record.send col}}.prepend(cols)
  end
end
