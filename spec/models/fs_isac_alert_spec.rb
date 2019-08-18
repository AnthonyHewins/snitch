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

  it {should validate_inclusion_of(:severity).in_range(
               FsIsacAlert::SEVERITY_MIN..FsIsacAlert::SEVERITY_MAX
             )}
    
  
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

    it 'sets a comment to something like "doesnt apply" if applies is false' do
      expect(create(:fs_isac_alert, applies: false).comment)
        .to eq "Auto-classified as DOES NOT APPLY."
    end
  end
end
