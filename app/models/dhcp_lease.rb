class DhcpLease < ApplicationRecord
  CsvColumns = [
    lambda {|i| i.paper_trail.insertion_date},
    :ip
  ]

  belongs_to :paper_trail, optional: false
  belongs_to :machine, optional: true
  has_one :uri_entry, dependent: :destroy
end
