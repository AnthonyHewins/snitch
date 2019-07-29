require 'rails_helper'
require 'mail/mail_parsers/mail_parser'

RSpec.describe MailParser do
  before :all do
    @concrete_class = Class.new
  end

  before :each do
    @obj = @concrete_class.new
    @obj.extend MailParser
  end

  subject {@obj}
  it {should have_abstract_method :parse}
  
  context "protected:" do
      before :each do
        @random = FFaker::Lorem.word
        @obj.instance_variable_set :@string, "1BEGIN#{@random}END1"
      end

    context '#find_then_eat(start, stop)' do
      it 'returns everything between start and stop in @string' do
        expect(@obj.send :find_then_eat, "1BEGIN", "END1").to eq @random
      end

      it 'kills off all the text from @string that it seeked out for its target text' do
        @obj.send :find_then_eat, "1BEGIN", "END"
        expect(@obj.instance_variable_get :@string).to eq "1"
      end
    end

    context '#kill_off_everything_before(start)' do
      it 'returns @string if start.nil?' do
        expect(@obj.send :kill_off_everything_before, nil)
          .to be @obj.instance_variable_get :@string
      end

      it 'kills everything at and before start from @string' do
        expect(@obj.send :kill_off_everything_before, "N").to eq "#{@random}END1"
      end
    end
  end
end
