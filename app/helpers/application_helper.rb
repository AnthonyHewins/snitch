module ApplicationHelper
  def select_in_dropdown(var)
    case var
    when Symbol
      jquery_str params[var]&.split(',')
    when ActiveRecord::Relation
      jquery_str var.map {|i| i.id.to_s}
    when Array
      jquery_str var.map {|i| i.respond_to?(:id) ? i.id.to_s : i.to_s}
    when Integer
      jquery_str var
    when ActiveRecord::Base
      jquery_str var.id
    else
      raise TypeError
    end
  end

  private
  def jquery_str(collection)
    collection.to_s.html_safe
  end
end
