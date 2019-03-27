require 'uri'
require 'date'
require 'ipaddr'

require_relative './application_record'

class UriEntry < ApplicationRecord
  CsvColumns = [
    :id,
    proc {|record| record.machine.ip},
    proc {|record| record.machine.user},
    proc {|record| record.machine.host},
    :uri,
    :hits,
    proc {|record| record.paper_trail&.insertion_date},
    :created_at,
    :updated_at
  ]

  belongs_to :machine
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
  
  def self.[](machine)
    case machine
    when Integer
      UriEntry.where machine_id: machine
    when Machine
      UriEntry.where machine: machine
    when IPAddr
      UriEntry.where machine: Machine.find_by(ip: machine)
    when String
      begin
        UriEntry.where machine: Machine.find_by(ip: IPAddr.new(machine))
      rescue
        UriEntry.where machine: Machine.where('host = :param or user = :param', {param: machine}).take
      end
    else
      raise TypeError, "#{machine.class} cannot be used to omnisearch for a Machine."
    end
  end
end
