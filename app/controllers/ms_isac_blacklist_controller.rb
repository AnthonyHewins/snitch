require Rails.root.join 'lib/assets/blacklist/blacklist_manager'

class MsIsacBlacklistController < ApplicationController
  def pull_from_exchange
    begin
      BlacklistManager.new.update_blacklist
      flash.now[:info] = "Successfully pulled IPs/domains down"
    rescue
      flash.now[:red] = "Error pulling down IPs: check error logs"
    end

    redirect_to root_path
  end
end
