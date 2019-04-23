require 'rails_helper'
require 'concerns/regex_validatable'

RSpec.describe Concerns::RegexValidatable do
  before :each do
    @obj = create :whitelist
  end

  context '#validate_regex' do
    it 'doesnt add an error if Regexp.new @regex_string succeeds' do
      @obj[:regex_string] = "[0-9]"
      @obj.send :validate_regex
      expect(@obj.errors[:regex_string].size).to eq 0
    end

    it 'adds an error if theres a problem with @regex_string' do
      @obj[:regex_string] = "[0-"
      @obj.send :validate_regex
      expect(@obj.errors[:regex_string].size).not_to eq 0
    end
  end
end
