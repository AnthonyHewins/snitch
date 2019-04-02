require_relative 'reportable_endpoint'

module DataLogEndpoint
  include ReportableEndpoint
  
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
end
