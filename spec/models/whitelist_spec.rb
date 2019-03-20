require 'spec_helper'
require 'whitelist'

RSpec.describe Whitelist, type: :model do
  it {should belong_to(:paper_trail).required(false)}
  
  before :each do
    @obj = create :whitelist
  end
  
  context '#regex' do
    it 'should proxy the value for regex_string in @regex_obj as a regex' do
      expect(@obj.regex).to eq Regexp.new(@obj.regex_string)
    end
  end

  context '#regex_string=' do
    it 'should update the value for @regex_obj if regex_string ever changes' do
      @obj.regex_string = "new"
      expect(@obj.regex).to eq Regexp.new("new")
    end
  end
end
