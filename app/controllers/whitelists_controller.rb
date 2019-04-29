require 'concerns/authenticatable'
require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/whitelist_log'

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
