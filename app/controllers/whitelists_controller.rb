require 'application_controller'
require 'concerns/authenticatable'
require 'concerns/data_log_endpoint'
require 'log_parsers/whitelist_log'

class WhitelistsController < ApplicationController
  include Authenticatable
  include DataLogEndpoint
  
  before_action :check_if_logged_in

  def index
    @whitelists = filter Whitelist
    respond @whitelists
  end

  # POST /whitelists/upload
  def insert_data
    get_log WhitelistLog, redirect: whitelists_path, fallback: whitelists_upload_path
  end
end
