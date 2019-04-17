require 'cyber_adapt_alert'

require_relative 'application_controller'

require Rails.root.join 'lib/assets/mail/mail_clients/cyber_adapt_mail_client'
require Rails.root.join 'lib/assets/mail/mail_parsers/cyber_adapt_mail_parser'
require Rails.root.join 'lib/assets/alert_endpoint'

class CyberAdaptAlertsController < ApplicationController
  include AlertEndpoint

  before_action :set_alert, only: %i(set_resolved show edit update)

  def index
    @alerts = filter(CyberAdaptAlert).order 'resolved asc, alert_id desc'
    respond @alerts
  end

  def show
  end

  def edit
  end

  def update
    @alert.update alert_params
    flash[:info] = "Updated CyberAdapt alert ##{@alert.alert_id}"
    redirect_to cyber_adapt_alert_path(@alert)
  end

  def pull_from_exchange
    already_have = Set.new CyberAdaptAlert.pluck(:alert_id)
    insert_everything_not_in already_have
    redirect_to cyber_adapt_alerts_path
  end

  def set_resolved
    resolve_alert(@alert, cyber_adapt_alerts_path)
  end

  private
  def set_alert
    @alert = CyberAdaptAlert.find params[:id]
  end

  def alert_params
    params.require(:cyber_adapt_alert).permit(:comment, :resolved)
  end
  
  def insert_everything_not_in(whats_in_db_already)
    email_parser = CyberAdaptMailParser.new
    CyberAdaptMailClient.new.get_missing(whats_in_db_already).each do |email|
      CyberAdaptAlert.create email_parser.parse(email.body)
    end
  end
end
