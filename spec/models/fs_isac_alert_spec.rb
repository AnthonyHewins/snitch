require 'rails_helper'
require 'fs_isac_alert'

RSpec.describe FsIsacAlert, type: :model do
  before :each do
    @obj = create :fs_isac_alert
  end
  
  subject {@obj}
  it {should validate_inclusion_of(:tracking_id).in_range(1..2147483647)}

  %i(title alert affected_products corrective_action sources).each do |sym|
    it {should validate_presence_of(sym)}
  end

  context 'before_save' do
    %i(title alert affected_products corrective_action sources).each do |sym|
      it "squishes text from :#{sym}" do
        old = @obj.send sym
        @obj.update sym => "\n#{old} \n\r\n #{old} \n" 
        expect(@obj.send(sym)).to eq "#{old} #{old}"
      end

      it 'removes commas so its CSV friendly' do
        old = @obj.send sym
        @obj.update sym => ",,#{old},," 
        expect(@obj.send(sym)).to eq old
      end
    end
  end

  context '#to_a(cols)' do
    it 'should returns self.map FsIsacAlert.column_names.map &:to_sym on cols.nil?' do
      expect(@obj.to_a).to eq FsIsacAlert.column_names.map {|i| @obj.send(i.to_sym)}
    end

    it 'should return cols.map {|i| self.send i}' do
      expect(@obj.to_a(:title)).to eq [@obj.title]
    end
  end
end