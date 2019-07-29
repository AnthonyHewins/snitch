require_relative 'application_controller'
require 'concerns/authenticatable'
require 'concerns/alert_endpoint'

require 'fs_isac_alert'

require 'mail/mail_clients/fs_isac_mail_client'
require 'mail/mail_parsers/fs_isac_mail_parser'

class FsIsacAlertsController < ApplicationController
  include Authenticatable
  include AlertEndpoint

  before_action :check_if_logged_in
  before_action :set_alert, only: %i(set_booleans show edit update)

  def index
    @alerts = filter(FsIsacAlert)
                .order 'applies desc, resolved asc, alert_timestamp desc, tracking_id desc'
    respond @alerts
  end

  def show
  end

  def update
    @alert.update fs_isac_alert_params
    flash[:info] = "Updated FS-ISAC alert ##{@alert.tracking_id}"
    redirect_to fs_isac_alerts_path
  end

  def set_booleans
    boolean_update fs_isac_alerts_path, @alert, :resolved, :applies
  end

  def pull_from_exchange
    already_have = Set.new FsIsacAlert.pluck :tracking_id
    insert_from_exchange_except already_have, FsIsacIgnore.all_regexps
    redirect_to fs_isac_alerts_path
  end

  private
  def set_alert
    @alert = FsIsacAlert.find params[:id]
  end

  def insert_from_exchange_except(ids_already_inserted, ignorable_alerts)
    parser = FsIsacMailParser.new

    FsIsacMailClient.new.get_missing([]).each do |email|
      hash = parser.parse(email.body)
      next if ids_already_inserted.include? hash[:tracking_id].to_i
      hash[:applies] = false if ignorable_alerts.any? {|i| i.match? hash[:title]}
      FsIsacAlert.create hash
    end
  end

  def fs_isac_alert_params
    params.require(:fs_isac_alert).permit :comment, :resolved, :applies
  end
end
