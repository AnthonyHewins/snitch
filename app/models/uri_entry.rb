require 'uri'

require 'application_record'
require 'machine'

class UriEntry < ApplicationRecord
  CsvColumns = [
    :id,
    proc {|record| record.dhcp_lease.ip},
    proc {|record| record.machine.user},
    proc {|record| record.machine.host},
    :uri,
    :hits,
    proc {|record| record.paper_trail&.insertion_date},
    :created_at,
    :updated_at
  ]

  has_one :dhcp_lease, required: true, dependent: :destroy
  belongs_to :paper_trail, optional: true

  validates :uri, format: {with: URI::regexp}
  validates_numericality_of :hits, only_integer: true, greater_than: 0

  def url
    @url ||= URI(self.uri)
  end

  def uri=(*args)
    @url = URI(args.first)
    super(*args)
  end

  def to_a(*cols)
    cols.empty? ? super(*CsvColumns) : super(*cols)
  end

  def machine
    dhcp_lease.machine
  end
  
  def self.[](machine)
    case machine
    when Integer
      UriEntry.where machine_id: machine
    when Machine
      UriEntry.where machine: machine
    when String
      UriEntry.where machine: Machine.where('host = :param or user = :param', {param: machine}).take
    else
      raise TypeError, "#{machine.class} cannot be used to omnisearch for a Machine."
    end
  end
end
