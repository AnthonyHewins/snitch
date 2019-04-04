class DhcpLease < ApplicationRecord
  belongs_to :paper_trail, optional: false
  belongs_to :machine
end
