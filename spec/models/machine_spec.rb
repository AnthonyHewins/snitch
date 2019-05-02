require 'rails_helper'
require 'machine'

RSpec.describe Machine, type: :model do
  it {should belong_to(:paper_trail).required(false)}
  it {should belong_to(:department).required(false)}
  it {should validate_uniqueness_of(:user).case_insensitive.allow_nil}
  it {should validate_uniqueness_of(:host).case_insensitive.allow_nil}

  before :each do
    @obj = create :machine
  end

  context 'before_save' do
    %i(user host).each do |sym|
      it "should downcase :#{sym} if non-nil" do
        @obj.update(sym => 'A')
        expect(@obj.reload.read_attribute sym).to eq 'a'
      end
    end

    it 'should remove the "flexibleplan\\" domain from :host, if present' do
      expect(create(:machine, host: 'flexibleplan\\A').host).to eq 'a'
    end
  end

  context 'scope(:search)' do
    %i(user host).each do |sym|
      it "finds based on :#{sym}" do
        expect(Machine.search @obj.send(sym)).to include @obj
      end
    end

    it 'finds based on paper_trail.insertion_date' do
      expect(Machine.search @obj.paper_trail.insertion_date).to include @obj
    end

    context 'finds the machine by its latest known ip' do
      before :each do
        @old = create :paper_trail, insertion_date: Date.today
        @new = create :paper_trail, insertion_date: Date.today + 1

        @old_lease = create :dhcp_lease, machine: @obj, paper_trail: @old
        @new_lease = create :dhcp_lease, machine: @obj, paper_trail: @new
      end
      
      it '' do
        expect(Machine.search @new_lease.ip).to include @obj
      end
      
      it 'and not the past ones it had, so long as something new took its place' do
        create :dhcp_lease, machine: create(:machine), paper_trail: @new, ip: @old_lease.ip
        expect(Machine.search @old_lease.ip).to_not include @obj
      end
    end
  end

  context '#ip(date=nil)' do
    it 'on NilClass returns self.last_known_ip' do
      expect(@obj.ip).to eq @obj.send(:last_known_ip)
    end

    [Date.today, DateTime.now].each do |date|
      it "on #{date.class} returns ip_on_date(date)" do
        expect(@obj.ip(date)).to eq @obj.send(:ip_on_date, date)
      end
    end

    it "on PaperTrail returns ip_on_date(date.insertion_date)" do
      expect(@obj.ip(@obj.paper_trail))
        .to eq @obj.send(:ip_on_date, @obj.paper_trail.insertion_date)
    end

    it 'raises TypeError on anything else' do
      expect{@obj.ip(1)}.to raise_error TypeError
    end
  end
  
  context '#to_a' do
    it 'maps each element in CsvColumns to make the machine ready for CSV output' do
      expect(@obj.to_a).to eq([
                                @obj.id,
                                @obj.user,
                                @obj.host,
                                @obj.ip,
                                @obj.paper_trail&.insertion_date,
                                @obj.created_at,
                                @obj.updated_at
                              ])
    end
  end

  context 'private:' do
    context '#last_known_ip' do
      it 'retrieves the last known ip for that machine' do
        latest_lease = create :paper_trail, insertion_date: Date.today
        earlier_lease = create :paper_trail, insertion_date: (Date.today - 1)
        correct_ip = create :dhcp_lease, paper_trail: latest_lease, machine: @obj
        wrong_ip = create :dhcp_lease, paper_trail: earlier_lease, machine: @obj

        expect(@obj.send :last_known_ip).to eq correct_ip.ip
      end
    end

    context '#ip_on_date(date)' do
      it 'returns the ip on the date supplied for the given machine' do
        paper_trail = create :paper_trail
        correct_ip = create :dhcp_lease, paper_trail: paper_trail, machine: @obj
        wrong_ip = create :dhcp_lease, paper_trail: paper_trail 

        expect(@obj.send :ip_on_date, paper_trail.insertion_date).to eq correct_ip.ip
      end
    end
    
    context '#pluck_ip' do
      it 'raises an error when a block isnt given' do
        expect{@obj.send :pluck_ip}.to raise_error LocalJumpError
      end
      
      it 'runs yield(DhcpLease.left_outer_joins(:paper_trail)).limit(1).pluck(:ip).first' do
        correct_ip = create :dhcp_lease, machine: @obj
        wrong_ip = create :dhcp_lease, machine: @obj

        expect(@obj.send(:pluck_ip) {|i| i}).to eq correct_ip.ip
      end
    end
  end
end
