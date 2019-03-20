require 'spec_helper'
require 'paper_trail'

RSpec.describe PaperTrail, type: :model do
  it {should have_many(:machines).dependent :nullify}
  it {should have_many(:uri_entries).dependent :nullify}
  it {should have_many(:whitelists).dependent :nullify}

  before :each do
    @obj = create :paper_trail
  end

  context 'before_save' do
    it 'allows type to be nil' do
      expect(create :paper_trail, log_type: nil).to be_valid
    end
  end
  
  context ':insertion_date' do
    it 'should not allowed to be nil' do
      expect(build(:paper_trail, insertion_date: nil)).to_not be_valid
    end
  end

  context '#model' do
    before :each do
      @obj.update log_type: "CarbonBlackLog"
    end

    it 'returns self.log_type.constantize' do
      expect(@obj.model).to eq CarbonBlackLog
    end

    it 'memoizes future calls with @model' do
      @obj.model
      expect(@obj.instance_variable_get :@model).to eq CarbonBlackLog
    end
  end

  context 'private:' do
    context '#check_valid_type' do
      it 'returns nil if DataLog.descendants.include? arg' do
        expect(@obj.send :check_valid_type, DataLog.descendants.first).to be nil
      end

      it 'raises ActiveRecord::RecordNotSaved otherwise' do
        expect{@obj.send :check_valid_type, 1}.to raise_error ActiveRecord::RecordNotSaved
      end
    end
  end
end
