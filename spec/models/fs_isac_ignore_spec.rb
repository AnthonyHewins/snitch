require 'rails_helper'
require 'fs_isac_ignore'

RSpec.describe FsIsacIgnore, type: :model do
  before :each do
    @obj = create :fs_isac_ignore
  end

  subject {FsIsacIgnore}
  it {should include Concerns::RegexValidatable}

  context '::all_regexps' do
    it 'should return every regex in the DB' do
      expect(FsIsacIgnore.all_regexps).to eq [@obj.regex]
    end
  end

  context '#regex' do
    it 'should proxy the value for regex_string in @regex_obj as a regex' do
      regex = Regexp.new(@obj.regex_string, @obj.case_sensitive? ? nil : 'i')
      expect(@obj.regex).to eq regex
    end
  end

  context '#regex_string=' do
    it 'should update the value for @regex_obj if regex_string ever changes' do
      @obj.regex_string = "new"
      expect(@obj.regex).to eq Regexp.new("new", @obj.case_sensitive ? nil : 'i')
    end
  end

  context '#case_sensitive=' do
    it 'should update the value for @regex_obj' do
      @obj.case_sensitive = !@obj.case_sensitive
      regex = Regexp.new(@obj.regex_string, @obj.case_sensitive? ? nil : 'i')
      expect(@obj.regex).to eq regex
    end
  end
end
