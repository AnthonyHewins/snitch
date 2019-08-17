require 'application_controller'
require 'concerns/authenticatable'
require 'concerns/data_log_endpoint'
require 'log_parsers/whitelist_log'

class WhitelistsController < ApplicationController
  include Authenticatable
  include DataLogEndpoint
  
  before_action :check_if_logged_in

  def index
    @whitelists = Whitelist.where 'regex_string ilike ?', "%#{params[:q]}%"
    respond_to do |f|
      f.html do
        @whitelists = @whitelists.paginate(page: params[:page], per_page: 100)
      end
      f.csv do
        respond @whitelists
      end
    end
  end

  # POST /whitelists/upload
  def insert_data
    get_log WhitelistLog, redirect: whitelists_path, fallback: whitelists_upload_path
  end
end
