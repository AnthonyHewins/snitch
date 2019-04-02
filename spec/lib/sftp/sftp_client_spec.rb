require 'spec_helper'
require_relative '../../../lib/assets/sftp/sftp_client'

RSpec.describe SftpClient do
  subject {SftpClient.new nil, nil}
  it {should have_attr_accessor :host}
  it {should have_attr_accessor :user}
  it {should have_attr_accessor :opts}
  
  before :all do
    @struct = Struct.new :name
  end

  before :each do
    @obj = SftpClient.new('test.rebex.net', 'demo', password: 'password')
  end

  context '#pull(opts={}, &proc_filter)' do
    it "downloads a files from test.rebex.net matching /[a-z]*.txt/ (should be a readme)" do
      test_file = SftpFile.new(
        filename: "readme.txt",
        text: File.read(Rails.root.join 'spec/fixtures/readme.txt')
      )
      expect(@obj.pull(name: /[a-z]*.txt/i)).to eq test_file
    end
  end

  context 'private:' do
    context '#filter(files, criteria, &block)' do
      it 'returns the first arg if nothing matches' do
        expect(@obj.send :filter, [], nil).to be nil
      end

      it 'always runs both checks if you supply them, even if that means rejecting all files' do
        files = [@struct.new('a')]
        expect(@obj.send(:filter, files, 'a') {|i| i.name == 'b'}).to eq nil
      end
      
      it 'filters on the given block' do
        files = (1..3).map {|i| @struct.new(i)}
        expect(@obj.send(:filter, files, nil) {|f| f.name == 1}).to be files.first
      end

      it 'filters on all files ensuring each file.name == arg' do
        files = (1..3).to_a.map {|i| @struct.new i.to_s}
        expect(@obj.send(:filter, files, '2')).to be files[1]
      end

      it 'filters on both the arg and the block' do
        files = (1..3).to_a.map {|i| @struct.new i.to_s}
        files_dupe = files.dup
        expect(@obj.send(:filter, files, '2') {|i| i.name == '2'}).to be files_dupe[1]
      end

      it 'raises Errno::ENOENT if more than one file was found matching criteria' do
        files = [@struct.new('2')] * 2
        expect{@obj.send :filter, files, nil}.to raise_error Errno::ENOENT
      end
    end

    context '#filter_by_proc(files, &block)' do
      it 'returns files when block is nil because the caller has no filter' do
        files = [1]
        expect(@obj.send :filter_by_proc, files).to be files
      end

      it 'when block.arity is 1, runs files.select &block to validate properties on each file' do
        files = [2, 3, 4] + ([1] * 4)
        expect(@obj.send(:filter_by_proc, files) {|i| i == 1}).to eq [1] * 4
      end

      context 'when block.arity is 2' do
        it 'and file.length == 1, returns files.first because theres nothing to compare to' do
          files = [1]
          expect(@obj.send(:filter_by_proc, files) {|i,j| j}).to be files
        end

        it 'returns files.inject(&block), expecting the user to make use of the comparison interface' do
          files = (0..5).to_a
          expect(@obj.send(:filter_by_proc, files) {|i,j| i < j ? j : i}).to eq [5]
        end
      end

      it 'raises ArgumentError if !(1..2).include?(block.arity)' do
        expect{@obj.send(:filter_by_proc, nil) {1}}.to raise_error ArgumentError
      end
    end
    
    context '#filter_by_name(files, criteria)' do
      it 'when arg2 is a string finds the first instance with that filename and wraps in Array' do
        x = @struct.new('a')
        expect(@obj.send :filter_by_name, [x] * 2, 'a').to eq [x]
      end

      it 'when arg2 is a regex selects only the things matching arg' do
        x = [@struct.new('a'), @struct.new('b'), @struct.new('b')]
        expect(@obj.send :filter_by_name, x, /b/).to eq x.slice(1..2)
      end

      it 'when arg2 is NilClass it returns files because caller has no filter' do
        files = [1]
        expect(@obj.send :filter_by_name, files, nil).to be files
      end

      it 'else it raises TypeError' do
        expect{@obj.send :filter_by_name, [], 1}.to raise_error TypeError
      end
    end
  end
end
