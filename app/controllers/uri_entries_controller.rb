require 'concerns/authenticatable'
require_relative 'application_controller'
require 'data_log_endpoint'
require 'sftp/cyber_adapt_sftp_client'
require 'log_parsers/cyber_adapt_log'

class UriEntriesController < ApplicationController
  include Authenticatable
  include DataLogEndpoint

  before_action :check_if_logged_in

  def index
    @uri_entries = filter(UriEntry).order('paper_trails.insertion_date desc')
    respond @uri_entries
  end

  def pull_from_cyberadapt
    flash[:info] = open_sftp_and_upsert
    redirect_to uri_entries_path
  end

  private
  def open_sftp_and_upsert
    missing = CyberAdaptSftpClient.new.get_missing
    return "Already up to date" if missing.empty?
    missing.map {|file| upsert file}
  end

  def upsert(file)
    if file.nil?
      "File not found (if it's today's file, this means CyberAdapt hasn't made it yet)"
    else
      log = CyberAdaptLog.new file
      "#{log.filename}: upserted #{log.clean.size}, had #{log.dirty.size} errors"
    end
  end
end
