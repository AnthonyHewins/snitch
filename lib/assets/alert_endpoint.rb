require_relative 'reportable_endpoint'

module AlertEndpoint
  include ReportableEndpoint
  extend ActiveSupport::Concern

  def resolve_alert(record, redirect)
    resolved = params[:resolved] == "true"
    record.update resolved: resolved
    flash[:info] = "Marked alert #{record.id} as #{'un' if !resolved}resolved"
    redirect_to redirect
  end
end
