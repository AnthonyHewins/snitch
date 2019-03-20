require Rails.root.join 'lib/assets/sftp/cyber_adapt_sftp_client'

class UriEntriesController < ApplicationController
  before_action :pull_from_cyberadapt
  
  def index
  end

  def upload
  end

  def show
  end

  private
  def pull_from_cyberadapt
    begin
      sftp = CyberAdaptSftpClient.new
      @pull_status = sftp.pull_latest.text
    rescue Exception => e
      @pull_status = e
    end
  end
end
