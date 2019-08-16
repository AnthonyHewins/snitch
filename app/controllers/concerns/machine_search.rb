require_relative 'searchable'
require 'machine'

module MachineSearch
  include Searchable

  JOIN = "left outer join paper_trails pt on pt.id = machines.paper_trail_id
          left outer join (
           select distinct on(dhcp_leases.ip) dhcp_leases.ip, dhcp_leases.machine_id
           from dhcp_leases
           left outer join paper_trails on paper_trails.id = dhcp_leases.paper_trail_id
           order by dhcp_leases.ip, paper_trails.insertion_date desc
         ) x on x.machine_id = machines.id".squish.freeze

  def filter
    filter_by_department(
      filter_by_user_data(
        filter_by_timestamp(
          filter_by_id(dhcp_search)
        )
      )
    )
  end

  private
  def dhcp_search
    Machine.select('x.ip, machines.*').joins(JOIN).where( 
      "pt.insertion_date >= :start and pt.insertion_date <= :stop
       or text(x.ip) like :ip",
      ip: "%#{params[:ip]}%",
      start: date_parse(:dhcp_date_start),
      stop: date_parse(:dhcp_date_end)
    )
  end

  def filter_by_user_data(query)
    host, user = params[:host], params[:user]
    query = query.where('host ilike ?', "%#{host}%") unless host.blank?
    query = query.where('machines.user ilike ?', "%#{user}%") unless user.blank?
    query
  end

  def filter_by_department(query)
    return query unless params.key? :department
    query.where department_id: params[:department]
  end
end
