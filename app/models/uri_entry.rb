require 'uri'

require 'application_record'
require 'concerns/uri_entry_hook'
require 'machine'

class UriEntry < ApplicationRecord
  include UriEntryHook

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
