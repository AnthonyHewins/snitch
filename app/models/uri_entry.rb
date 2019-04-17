require 'uri'

require 'application_record'
require 'machine'

class UriEntry < ApplicationRecord
  CsvColumns = [
    :id,
    proc {|record| record.dhcp_lease.ip},
    proc {|record| record.machine&.user},
    proc {|record| record.machine&.host},
    :uri,
    :hits,
    proc {|record| record.paper_trail&.insertion_date},
    :created_at,
    :updated_at
  ]

  belongs_to :dhcp_lease, required: true
  belongs_to :paper_trail, optional: true

  validates :uri, format: {with: URI::regexp}
  validates_numericality_of :hits, only_integer: true, greater_than: 0

  scope :search, lambda {|q|
    select('x.user, x.host, x.ip, uri_entries.*').joins(
      "left outer join paper_trails on paper_trails.id = uri_entries.paper_trail_id
       inner join (
             select d.id, d.ip, ma.user, ma.host from dhcp_leases d
             left outer join machines ma on ma.id = d.machine_id
       ) x on x.id = uri_entries.dhcp_lease_id"
    ).where <<-SQL, q: "%#{q}%"
       TEXT(x.ip) like :q or x.host like :q or x.user like :q
       or uri like :q or TEXT(paper_trails.insertion_date) like :q
    SQL
  }

  def url
    @url ||= URI(self.uri)
  end

  def uri=(*args)
    @url = URI(args.first)
    super(*args)
  end

  def machine
    dhcp_lease.machine
  end
end
