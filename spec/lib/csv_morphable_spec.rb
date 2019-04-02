require 'spec_helper'
require_relative '../../lib/assets/csv_morphable'

RSpec.describe CsvMorphable do
  before :all do
    @dummy = Class.new
    @dummy.include CsvMorphable
    @obj = @dummy.new
  end

  context '#to_a(*procs_and_syms)' do
    it 'on an Array with Proc elements, it calls the proc on self' do
      expect(@obj.to_a proc {|i| i.object_id}).to eq [@obj.object_id]
    end

    ['object_id', :object_id].each do |sendable|
      it "on an Array with #{sendable.class} elements it maps the Symbol to self" do
        expect(@obj.to_a sendable).to eq [@obj.object_id]
      end
    end

    it 'throws TypeError on all other types' do
      expect{@obj.to_a 1}.to raise_error TypeError
    end
  end
end
