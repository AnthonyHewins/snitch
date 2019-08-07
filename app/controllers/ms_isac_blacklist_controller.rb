require 'viewpoint'

require 'blacklist/blacklist_manager'

class MsIsacBlacklistController < ApplicationController
  def pull_from_exchange
    begin
      BlacklistManager.new.update_blacklist
      flash.now[:info] = "Successfully pulled IPs/domains down"
    rescue Viewpoint::EWS::Errors::UnauthorizedResponseError
      flash[:error] = "There's a problem connecting to Outlook. Is everything okay with the server?"
    rescue Exception => e
      flash[:error] = "Error pulling down IPs: #{e}"
    end

    redirect_to root_path
  end
end
