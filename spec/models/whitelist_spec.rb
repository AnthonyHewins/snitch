require 'rails_helper'
require 'whitelist'

RSpec.describe Whitelist, type: :model do
  before :each do
    @obj = create :whitelist
  end

  subject {@obj}
  it {should belong_to(:paper_trail).required(false)}

  it 'should include Concerns::RegexValidatable' do
    expect(Whitelist).to include Concerns::RegexValidatable
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

  context 'after_save' do
    it 'should delete any UriEntry that matches its regex_string' do
      create :uri_entry, uri: "http://g123.com"
      expect{@obj.update regex_string: "g[0-9]*.com"}
        .to change{UriEntry.count}.from(1).to(0)
    end
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
