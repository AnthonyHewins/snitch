require 'application_controller'
require 'concerns/authenticatable'
require 'concerns/data_log_endpoint'
require 'log_parsers/whitelist_log'

class WhitelistsController < ApplicationController
  include Authenticatable
  include DataLogEndpoint
  
  before_action :check_if_logged_in
  before_action :set_whitelist, only: %i[edit update destroy]

  def index
    @whitelists = Whitelist.where('regex_string ilike ?', "%#{params[:q]}%")
                    .paginate(page: params[:page], per_page: 100)
  end

  def new
    @whitelist = Whitelist.new
  end

  def edit
  end

  def create
    @whitelist = Whitelist.new(whitelist_params)

    if @whitelist.save
      flash[:info] = "Whitelist was successfully created."
      redirect_to whitelists_path
    else
      flash.now[:error] = @whitelist.errors
      render :new
    end
  end

  def update
    if @whitelist.update(whitelist_params)
      flash[:info] = "Rule ID##{@whitelist.id} was successfully updated."
      redirect_to whitelists_path
    else
      flash.now[:error] = @whitelist.errors
      render :edit
    end
  end

  def destroy
    if @whitelist.destroy
      flash[:info] = "Rule ID##{@whitelist.id} was successfully destroyed."
      redirect_to whitelists_url
    else
      flash.now[:error] = @whitelist.errors
      render :index
    end
  end

  # POST /whitelists/upload
  def insert_data
    get_log WhitelistLog, redirect: whitelists_path, fallback: whitelists_upload_path
  end

  private
  def whitelist_params
    params.require(:whitelist).permit :regex_string
  end

  def set_whitelist
    @whitelist = Whitelist.find params[:id]
  end
end
