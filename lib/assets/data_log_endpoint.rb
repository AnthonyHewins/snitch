require_relative 'reportable_endpoint'

module DataLogEndpoint
  include ReportableEndpoint

  def get_log(log_class, redirect:, fallback:)
    log, date = params[:log], params[:recorded]
    begin
      insert_from_log log_class, log, date, redirect
    rescue ArgumentError
      flash[:error] = "Specify a date when the data was recorded,
                       or imply it in the default filename"
      redirect_to fallback
    end
  end

  private
  def insert_from_log(log_class, log, date, redirect)
    log = log_class.new log, recorded: date.blank? ? nil : Date.parse(date)
    flash[:info] = "#{log.filename}: #{log.dirty.size} error(s)"
    redirect_to redirect
  end
end
