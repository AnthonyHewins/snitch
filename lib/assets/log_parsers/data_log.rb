require 'csv'

require Rails.root.join 'app/models/paper_trail'
require_relative '../sftp/sftp_file'

class DataLog
  attr_reader :clean, :dirty, :filename, :date_override
  
  def initialize(csv, headers, date_override, timestamp_regex, type, &block)
    csv = parse_csv csv, headers
    @date_override = parse_timestamp_args date_override, timestamp_regex, type
    read csv, &block
  end

  protected
  def parse_row
    raise NotImplementedError
  end

  private
  def parse_csv(arg, headers)
    case arg
    when Pathname
      @filename = arg.to_path
      CSV.read(arg, headers: headers)
    when String
      @filename = arg
      CSV.read(arg, headers: headers)
    when File
      @filename = arg.path
      CSV.read(arg, headers: headers)
    when SftpFile
      @filename = arg.filename
      CSV.parse(arg.text, headers: headers)
    when CSV
      @filename = arg.path
      arg.read
    when CSV::Table, Array
      @filename = nil # @filename can't be known in this case
      arg
    else
      raise TypeError, "no implicit conversion from #{arg.class} to CSV"
    end
  end

  def read(csv, &block)
    @clean, @dirty = [], []
    csv.map(&block)
  end

  def parse_timestamp_args(date_override, regex, type)
    date = decide_on_timestamp(date_override, regex)
    case date
    when Date
      find_or_create_paper_trail date, type
    when DateTime
      find_or_create_paper_trail date.to_date, type
    when PaperTrail, NilClass
      date
    else
      raise TypeError, "date_override must be a Date or PaperTrail, got #{date.class}"
    end
  end

  def decide_on_timestamp(date_override, regex)
    return date_override unless date_override.nil?
    regex.nil? ? nil : Date.parse(regex.match(@filename).to_s)
  end
  
  def find_or_create_paper_trail(insertion_date, type)
    PaperTrail.find_or_create_by(
      insertion_date: insertion_date,
      filename: @filename,
      log_type: type.to_s
    )
  end
end
