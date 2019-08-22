module Searchable
  def filter
    raise NotImplementedError
  end

  protected
  def filter_by_id(query)
    start = Integer(params[:id_start]) rescue 0
    stop = Integer(params[:id_end]) rescue Float::INFINITY
    query.where id: start..stop
  end

  def filter_by_timestamp(query)
    created_start = date_parse(:created_at_start) || DateTime.new(0,1,1)
    updated_start = date_parse(:updated_at_start) || DateTime.new(0,1,1)

    created_end = date_parse(:created_at_end) || 1000.years.from_now
    updated_end = date_parse(:updated_at_end) || 1000.years.from_now

    query.where(created_at: created_start..created_end)
      .where(updated_at: updated_start..updated_end)
  end

  def date_parse(sym)
    DateTime.parse(params[sym]) rescue nil
  end

  def bool_check(sym)
    return nil unless params.key?(sym)
    params[sym] == "on" || params[sym] == "1" || params[sym] == "true"
  end
end
