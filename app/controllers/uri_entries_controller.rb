require_relative 'log_controller'
require Rails.root.join 'lib/assets/sftp/cyber_adapt_sftp_client'
require Rails.root.join 'lib/assets/log_parsers/cyber_adapt_log'

class UriEntriesController < LogController
  def index
    @uri_entries = UriEntry.all
  end

  def insert_data
    cyber_adapt_log = get_log CyberAdaptLog, params
    redirect_to uri_entries_path
  end

  def pull_from_cyberadapt
    flash[:info] = open_sftp_and_upsert
    redirect_to uri_entries_path
  end

  private
  def open_sftp_and_upsert
    date_range = dates_that_need_to_be_downloaded
    flash[:info] = "Already up to date" if date_range.empty?
    sftp = CyberAdaptSftpClient.new nil, nil, passphrase: "Alpha124816!"
    date_range.map {|date| sftp_download_and_upsert sftp, date}
  end

  def dates_that_need_to_be_downloaded
    next_date_needed = PaperTrail.select(:insertion_date).max.insertion_date + 1
    (next_date_needed..Date.today).to_a
  end
  
  def sftp_download_and_upsert(sftp, date)
    file = sftp.pull date
    return nil if file.nil?
    log = CyberAdaptLog.create_from_timestamped_file sftp.pull(date)
    "Upserted #{log.clean.size} and ran into #{log.dirty.size} errors"
  end
end
