require 'uri'

require 'application_record'
require 'concerns/uri_entry_hook'
require 'machine'

class UriEntry < ApplicationRecord
  include UriEntryHook

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
