require_relative 'application_controller'
require 'concerns/authenticatable'
require 'concerns/alert_endpoint'

require 'fs_isac_alert'

class FsIsacAlertsController < ApplicationController
  include Authenticatable
  include AlertEndpoint

  before_action :check_if_logged_in
  before_action :set_alert, only: %i(set_booleans show edit update)

  def index
    @alerts = filter(FsIsacAlert).order(
      'applies desc, resolved asc, severity desc, alert_timestamp desc, tracking_id desc'
    )
    respond @alerts
  end

  def show
  end

  def error
  end
  
  def update
    if @alert.update fs_isac_alert_params
      flash[:info] = "Updated FS-ISAC alert ##{@alert.tracking_id}"
      redirect_to fs_isac_alerts_path
    else
      flash.now[:red] = "Unable to edit alert ##{@alert.tracking_id}"
      render :edit
    end
  end

  def set_booleans
    boolean_update fs_isac_alerts_path, @alert, :resolved, :applies
  end

  def pull_from_exchange
    @errors = FsIsacAlert.create_from_exchange
    if @errors.empty?
      flash[:info] = "Successfully pulled down FS-ISAC alerts"
      redirect_to fs_isac_alerts_path
    else
      redirect_to error_fs_isac_alerts_path
    end
  end

  private
  def set_alert
    @alert = FsIsacAlert.find params[:id]
  end

  def fs_isac_alert_params
    params.require(:fs_isac_alert).permit :comment, :resolved, :applies, :severity
  end
end
