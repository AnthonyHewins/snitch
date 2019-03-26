module DataLogEndpoint
  def filter(model, search_fn:)
    query, show_all = params[:q], params[:all]
    if query.nil?
      show_all ? model.all : model.last(50)
    else
      results = search_fn.call query
      show_all ? results : results.last(50)
    end
  end

  def get_log(log_class, redirect:)
    log, date_override = params[:log], params[:date_override]
    log = infer_how_to_insert log_class, log, date_override
    flash[:info] = "#{log.filename}: upserted #{log.clean.size}, #{log.dirty.size} errors"
    redirect_to redirect
  end

  def infer_how_to_insert(log_class, log, date)
    date = date.blank? ? nil : Date.parse(date)
    if date.nil?
      log_class.create_from_timestamped_file(log)
    else
      log_class.new log, date_override: date
    end
  end
end
