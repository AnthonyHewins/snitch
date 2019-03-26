require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/sftp/cyber_adapt_sftp_client'
require Rails.root.join 'lib/assets/log_parsers/cyber_adapt_log'

class UriEntriesController < ApplicationController
  include DataLogEndpoint
  
  def index
    @uri_entries = filter UriEntry, search_fn: lambda {|x| search x}
  end

  def pull_from_cyberadapt
    flash[:info] = open_sftp_and_upsert
    redirect_to uri_entries_path
  end

  private
  def search(query)
    UriEntry.left_outer_joins(:machine).left_outer_joins(:paper_trail)
      .where <<-SQL, q: "%#{query}%"
         TEXT(machines.ip) like :q or machines.host like :q or machines.user like :q
         or uri like :q or TEXT(paper_trails.insertion_date) like :q
      SQL
  end

  def open_sftp_and_upsert
    missing = CyberAdaptSftpClient.new.get_missing
    return "Already up to date" if missing.empty?
    missing.map {|file| upsert file}
  end

  def upsert(file)
    if file.nil?
      "File not found (if it's today's file, this means CyberAdapt hasn't made it yet)"
    else
      log = CyberAdaptLog.create_from_timestamped_file file
      "#{log.filename}: upserted #{log.clean.size}, had #{log.dirty.size} errors"
    end
  end
end
