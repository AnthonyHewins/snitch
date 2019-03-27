module DataLogEndpoint
  def filter(model, search_fn:)
    query, show_all = params[:q], params[:all]
    if query.nil?
      show_all ? model.all : model.limit(50)
    else
      results = search_fn.call query
      show_all ? results : results.limit(50)
    end
  end

  def get_log(log_class, redirect:)
    log, date_override = params[:log], params[:date_override]
    log = infer_how_to_insert log_class, log, date_override
    flash[:info] = "#{log.filename}: #{log.dirty.size} error(s)"
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

  def respond(relation)
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-disposition'] = generate_disposition relation
        headers['Content-type'] ||= 'text/csv'
      end
    end
  end

  private
  def generate_disposition(relation)
    query, time = params[:q], DateTime.now.strftime("%Y%m%d%H%M")
    if query.blank?
      filename = "#{relation.model}_#{time}.csv"
    else
      # Substring the query so there's no overflow in the filename
      filename = "#{relation.model}_#{query[0..25]}_#{time}.csv"
    end
    "attachment; filename=\"#{filename}\""
  end
end
