require 'rails_helper'
require 'sftp/cyber_adapt_sftp_client'

RSpec.describe CyberAdaptSftpClient do
  before :each do
    @obj = CyberAdaptSftpClient.new
  end

  context '#initialize(host=nil, user=nil, opts={})' do
    it 'defaults @host to "remote.cyberadapt.com"' do
      expect(@obj.instance_variable_get :@host).to eq 'remote.cyberadapt.com'
    end

    it 'defaults @user to "flexplan"' do
      expect(@obj.instance_variable_get :@user).to eq 'flexplan'
    end

    it 'defaults @opts to {port: 2222, keys: ["~/.ssh/id_rsa"]}' do
      expect(@obj.instance_variable_get :@opts).to eq({port: 2222, keys: ['~/.ssh/id_rsa']})
    end
  end

  context 'private:' do
    context '#to_timestamped_filename(date)' do
      it 'returns a formatted string matching CyberAdapts naming convention' do
        expect(@obj.send :to_timestamped_filename, Date.today)
          .to eq "flexplan_srcip_host_#{Date.today.strftime("%Y%m%d")}.csv"
      end
    end
  end
end
