require 'spec_helper'
require_relative '../../../lib/assets/sftp/cyber_adapt_sftp_client'

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
    context '#duck_type_for_timestamped_filename(possible_date)' do
      it 'returns possible_date if it isnt a Date' do
        not_a_date = 1
        expect(@obj.send :duck_type_for_timestamped_filename, not_a_date).to be not_a_date
      end

      it 'returns a formatted string matching CyberAdapts naming convention' do
        expect(@obj.send :duck_type_for_timestamped_filename, Date.today)
          .to eq "flexplan_srcip_host_#{Date.today.strftime("%Y%m%d")}"
      end
    end
  end
end
