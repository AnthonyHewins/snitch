require 'csv'

require 'paper_trail'
require 'sftp/sftp_file'

class DataLog
  attr_reader :clean, :dirty, :filename, :recorded
  
  def initialize(csv, headers, recorded, &block)
    csv = parse_csv csv, headers
    @recorded = parse_timestamp_args recorded
    read csv, &block
  end

  protected
  def parse_row
    raise NotImplementedError
  end

  private
  def parse_csv(arg, headers)
    case arg
    when ActionDispatch::Http::UploadedFile
      @filename = arg.original_filename
      CSV.parse(arg.read, headers: headers)
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
    @dirty = []
    csv.map(&block)
  end

  def parse_timestamp_args(recorded)
    date = recorded || get_filename_timestamp
    case date
    when Date
      find_or_create_paper_trail date
    when DateTime
      find_or_create_paper_trail date.to_date
    when PaperTrail
      date
    else
      raise TypeError, "recorded must be a Date or PaperTrail, got #{date.class}"
    end
  end

  def get_filename_timestamp
    if self.class::FORMAT.match? @filename
      Date.parse(self.class::TIMESTAMP.match(@filename).to_s)
    else
      raise ArgumentError, "no recorded date provided & filename doesn't match #{self.class::FORMAT}"
    end
  end

  def find_or_create_paper_trail(insertion_date)
    PaperTrail.find_or_create_by(
      insertion_date: insertion_date,
      filename: @filename,
    )
  end
end
