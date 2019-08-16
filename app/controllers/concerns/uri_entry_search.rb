require 'uri_entry'
require_relative 'searchable'

module UriEntrySearch
  include Searchable

  JOIN = "left outer join paper_trails on paper_trails.id = uri_entries.paper_trail_id
         inner join (
           select d.id, d.ip, ma.user, ma.host from dhcp_leases d
           left outer join machines ma on ma.id = d.machine_id
         ) x on x.id = uri_entries.dhcp_lease_id"

  def filter
    filter_by_insertion_date(
      filter_by_timestamp(
        filter_by_uri_data(
          filter_by_id(filter_by_dhcp)
        )
      )
    ).limit(100)
  end

  private
  def filter_by_dhcp
    h, u, ip = params[:host], params[:user], params[:ip]
    q = UriEntry.select('x.user, x.host, x.ip, uri_entries.*').joins(JOIN)
    q = q.where('x.host ilike ?', "%#{h}%") unless h.blank?
    q = q.where('x.user ilike ?', "%#{u}%") unless u.blank?
    q = q.where('TEXT(x.ip) ilike ?', "%#{ip}%") unless ip.blank?
    q
  end

  def filter_by_uri_data(q)
    uri, h_start, h_end = params[:uri], params[:hits_start], params[:hits_end]
    q = q.where('uri ilike ?', "%#{uri}%") unless uri.blank?
    q = q.where('hits >= ?', h_start) unless h_start.blank?
    q = q.where('hits <= ?', h_end) unless h_end.blank?
    q
  end

  def filter_by_insertion_date(q)
    start, stop = date_parse(:dhcp_date_start), date_parse(:dhcp_date_end)
    q = q.where('paper_trails.insertion_date >= ?', start) if start
    q = q.where('paper_trails.insertion_date <= ?', stop) if stop
    q
  end
end
