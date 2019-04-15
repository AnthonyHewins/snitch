require 'fs_isac_alert'

require_relative 'application_controller'

require Rails.root.join 'lib/assets/mail/mail_clients/fs_isac_mail_client'
require Rails.root.join 'lib/assets/mail/mail_parsers/fs_isac_mail_parser'
require Rails.root.join 'lib/assets/alert_endpoint'

class FsIsacAlertsController < ApplicationController
  MODEL = FsIsacAlert

  include AlertEndpoint

  before_action :set_alert, only: %i(set_resolved show edit update)

  def index
    @alerts = filter(FsIsacAlert, search_fn: lambda {|x| search x})
                .order 'resolved asc, alert_timestamp desc'
    respond @alerts
  end

  def show
  end

  def update
    @alert.update fs_isac_alert_params
    flash[:info] = "Updated FS-ISAC alert ##{@alert.tracking_id}"
    redirect_to fs_isac_alerts_path
  end

  def set_resolved
    resolve_alert(@alert, fs_isac_alerts_path)
  end

  def pull_from_exchange
    already_have = Set.new FsIsacAlert.pluck :tracking_id
    insert_from_exchange_except already_have
    redirect_to fs_isac_alerts_path
  end

  private
  def set_alert
    @alert = FsIsacAlert.find params[:id]
  end

  def insert_from_exchange_except(ids_already_inserted)
    parser = FsIsacMailParser.new

    FsIsacMailClient.new.get_missing([]).each do |email|
      hash = parser.parse(email.body)
      next if ids_already_inserted.include? hash[:tracking_id].to_i
      FsIsacAlert.create hash
    end
  end
  
  def fs_isac_alert_params
    params.require(:fs_isac_alert).permit :comment, :resolved
  end
  
  def search(query)
    FsIsacAlert.where <<-SQL, q: "%#{query}%"
      title like :q
      or alert like :q
      or affected_products like :q
      or corrective_action like :q
      or sources like :q
      or TEXT(tracking_id) like :q
      or TEXT(alert_timestamp) like :q
    SQL
  end
end
