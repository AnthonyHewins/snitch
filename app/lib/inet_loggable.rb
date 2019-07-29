require 'dhcp_lease'

module InetLoggable
  protected
  def upsert_dhcp_lease
    raise NotImplementedError
  end

  def past_history_for_dhcp_lease(ip, date)
    DhcpLease.left_outer_joins(:paper_trail)
      .where(
        "ip = :ip and paper_trails.insertion_date = :date",
        date: date,
        ip: ip.to_s
      ).limit(1).first
  end
end
