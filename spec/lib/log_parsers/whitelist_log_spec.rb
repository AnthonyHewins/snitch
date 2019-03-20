require 'spec_helper'
require Rails.root.join 'lib/assets/log_parsers/whitelist_log'

RSpec.describe WhitelistLog do
  before :all do
    @filename = Rails.root.join('tmp/whitelist_log.csv').to_path
    @regex = FFaker::Lorem.word + "[0-9]*"
    CSV.open(@filename, 'wb') do |csv|
      csv << ['regex_string']
      csv << [@regex]
    end
  end

  it 'inherits from DataLog' do
    expect(WhitelistLog).to be < DataLog
  end

  context '#initialize reads in the CSV given with filename and' do
    it 'creates the whitelist element if the regex is valid' do
      expect{WhitelistLog.new @filename}.to change{Whitelist.count}.by 1
    end

    it 'files the Whitelist into @dirty if it has errors' do
      # Create an error in the CSV to force the read to put the Whitelist in @dirty
      file_with_errors = @filename + 'dirty'
      CSV.open(file_with_errors, 'wb') do |csv|
        csv << ['regex_string']
        csv << ["[0-"]
      end

      expect(WhitelistLog.new(file_with_errors).dirty.size).to eq 1
    end

    it 'files the Whitelist into @clean if it has no errors' do
      expect(WhitelistLog.new(@filename).clean.size).to eq 1
    end
  end
end
