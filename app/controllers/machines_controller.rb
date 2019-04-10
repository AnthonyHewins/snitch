require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < ApplicationController
  include DataLogEndpoint
  
  def index
    @machines = filter Machine, search_fn: lambda {|x| search x}
    respond @machines
  end

  # POST /machines/upload
  def insert_data
    get_log CarbonBlackLog, redirect: machines_path, fallback: machines_upload_path
  end

  private
  def search(query)
    join.where(
      "host like :q or machines.user like :q
       or TEXT(paper_trails.insertion_date) like :q
       or text(x.ip) like :q",
      q: "%#{query}%"
    )
  end

  def join
    Machine.select('x.ip, machines.*').joins(
      "left outer join paper_trails on paper_trails.id = machines.paper_trail_id
      left outer join (
        select distinct on(dhcp_leases.ip) dhcp_leases.ip, dhcp_leases.machine_id from dhcp_leases
        left outer join paper_trails on paper_trails.id = dhcp_leases.paper_trail_id
        order by dhcp_leases.ip, paper_trails.insertion_date desc
      ) x on x.machine_id = machines.id"
    )
  end
end
