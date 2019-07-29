require 'rails_helper'
require 'sftp/sftp_file'

RSpec.describe SftpFile do
  subject {SftpFile.new}
  it {should have_attr_accessor :filename}
  it {should have_attr_accessor :text}

  context '#==' do
    before :each do
      @obj1 = SftpFile.new(filename: '1', text: '2')
      @obj2 = SftpFile.new(filename: '1', text: '2')
    end

    it 'returns true if instance vars are equal and classes match' do
      expect(@obj1 == @obj2).to be true
    end

    it 'returns false otherwise' do
      @obj2.text << 'a'
      expect(@obj1 == @obj2).to be false
    end
  end
end
