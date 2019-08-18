require 'concerns/authenticatable'
require 'concerns/reportable_endpoint'

class FsIsacIgnoresController < ApplicationController
  include Authenticatable
  include ReportableEndpoint

  before_action :set_fs_isac_ignore, only: %i(show edit update destroy)
  before_action :check_if_logged_in

  def index
    @fs_isac_ignores = FsIsacIgnore.where('regex_string ilike ?', "%#{params[:q]}%")
                         .order(:id).paginate(page: params[:page], per_page: 100)
  end

  def new
    @fs_isac_ignore = FsIsacIgnore.new
  end

  def edit
  end

  def create
    @fs_isac_ignore = FsIsacIgnore.new(fs_isac_ignore_params)

    if @fs_isac_ignore.save
      flash[:info] = "Rule ID##{@fs_isac_ignore.id} was successfully created."
      redirect_to fs_isac_ignores_path
    else
      render :new
    end
  end

  def update
    if @fs_isac_ignore.update(fs_isac_ignore_params)
      flash[:info] = "Rule ID##{@fs_isac_ignore.id} was successfully updated."
      redirect_to fs_isac_ignores_path
    else
      render :edit
    end
  end

  def destroy
    @fs_isac_ignore.destroy
    flash[:info] = "Rule ID##{@fs_isac_ignore.id} was successfully destroyed."
    redirect_to fs_isac_ignores_url
  end

  private
  def set_fs_isac_ignore
    @fs_isac_ignore = FsIsacIgnore.find(params[:id])
  end

  def fs_isac_ignore_params
    params.require(:fs_isac_ignore).permit :regex_string, :case_sensitive
  end
end
