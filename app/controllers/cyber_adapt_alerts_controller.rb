require 'cyber_adapt_alert'

require_relative 'application_controller'

require Rails.root.join 'lib/assets/mail/cyber_adapt_mail_client'
require Rails.root.join 'lib/assets/mail/cyber_adapt_mail_parser'
require Rails.root.join 'lib/assets/reportable_endpoint'

class CyberAdaptAlertsController < ApplicationController
  include ReportableEndpoint

  before_action :set_alert, only: %i(set_resolved show edit update)
  
  def index
    @alerts = filter(CyberAdaptAlert, search_fn: lambda {|x| search x})
                .order 'resolved asc, alert_id desc'
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

  def set_resolved
    resolved = params[:resolved] == "true"
    @alert.update resolved: resolved
    flash[:info] = "Marked alert #{@alert.alert_id} as #{'un' if !resolved}resolved"
    redirect_to cyber_adapt_alerts_path
  end
  
  def pull_from_exchange
    already_have = Set.new CyberAdaptAlert.pluck(:alert_id)
    insert_everything_not_in already_have
    redirect_to cyber_adapt_alerts_path
  end

  private
  def set_alert
    @alert = CyberAdaptAlert.find params[:id]
  end

  def alert_params
    params.require(:cyber_adapt_alert).permit(:comment, :resolved)
  end
  
  def search(query)
    CyberAdaptAlert.where <<-SQL, q: "%#{query}%"
      msg like :q
      or TEXT(alert_id) like :q
      or TEXT(alert_timestamp) like :q
      or TEXT(src_ip) like :q
      or TEXT(dst_ip) like :q
      or TEXT(src_port) like :q
      or TEXT(dst_port) like :q
    SQL
  end
  
  def insert_everything_not_in(whats_in_db_already)
    email_parser = CyberAdaptMailParser.new
    CyberAdaptMailClient.new.get_missing(whats_in_db_already).each do |email|
      CyberAdaptAlert.create email_parser.parse(email.body)
    end
  end
end
