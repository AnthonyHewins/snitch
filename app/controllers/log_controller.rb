class LogController < ApplicationController
  protected
  def get_log(log_class, params)
    log, date_override = params[:log], parse_date_override(params[:date_override])

    if date_override.nil?
      infer_how_to_insert log_class, log
    else
      log_class.new log, date_override: date_override
    end
  end

  def parse_date_override(date)
    date.blank? ? nil : Date.parse(date)
  end

  def infer_how_to_insert(log_class, log)
    return log_class.new(log) unless log_class::FORMAT.match? log.original_filename
    log_class.create_from_timestamped_file(log) rescue log_class.new(log)
  end
end
