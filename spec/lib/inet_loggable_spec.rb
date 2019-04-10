require 'rails_helper'
require Rails.root.join 'lib/assets/inet_loggable'

RSpec.describe InetLoggable do
  before :all do
    @dummy = Class.new
    @dummy.include InetLoggable
    @obj = @dummy.new
  end

  subject {@obj}
  it {should have_abstract_method :upsert_dhcp_lease}
  
  context '#past_history_for_dhcp_lease(ip, date)' do
    it 'returns the DhcpLease for an IP on self.recorded.insertion_date' do
      paper_trail = create :paper_trail
      lease = create :dhcp_lease, paper_trail: paper_trail
      expect(
        @obj.send(:past_history_for_dhcp_lease, lease.ip, paper_trail.insertion_date)
      ).to eq lease
    end
  end
end
