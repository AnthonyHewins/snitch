require 'csv'
require 'viewpoint'

require 'application_controller'
require 'concerns/fs_isac_alert_search'
require 'concerns/authenticatable'
require 'concerns/alert_endpoint'
require 'concerns/reportable_endpoint'

require 'fs_isac_alert'

class FsIsacAlertsController < ApplicationController
  include FsIsacAlertSearch
  include Authenticatable
  include AlertEndpoint
  include ReportableEndpoint

  ORDER = 'applies desc, resolved asc, severity desc, alert_timestamp desc, tracking_id desc'
  
  before_action :check_if_logged_in
  before_action :set_alert, only: %i(set_booleans show edit update)

  def index
    @alerts = filter.order(ORDER)
    respond_to do |f|
      f.html do
        @alerts = @alerts.paginate(page: params[:page], per_page: 100)
      end
      f.csv do
        respond @alerts
      end
    end
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
      flash.now[:red] = @alert.errors
      render :edit
    end
  end

  def set_booleans
    boolean_update fs_isac_alerts_path, @alert, :resolved, :applies
  end

  def pull_from_exchange
    @errors = get_new_alerts
    if @errors.empty?
      flash[:info] = "Successfully pulled down FS-ISAC alerts"
      redirect_to fs_isac_alerts_path
    else
      render :error
    end
  end

  private
  def set_alert
    @alert = FsIsacAlert.find params[:id]
  end

  def fs_isac_alert_params
    params.require(:fs_isac_alert).permit :comment, :resolved, :applies, :severity
  end

  def get_new_alerts
    begin
      FsIsacAlert.create_from_exchange
    rescue Viewpoint::EWS::Errors::UnauthorizedResponseError => e
      [[e, "There was an error trying to connect to the outlook server"]]
    end
  end
end
