require 'active_support/concern'

module UriEntryHook
  extend ActiveSupport::Concern

  included do
    belongs_to :dhcp_lease, required: true
    belongs_to :paper_trail, required: false

    validates :uri, format: {with: URI::regexp}
    validates_numericality_of :hits, only_integer: true, greater_than: 0
  end
end
