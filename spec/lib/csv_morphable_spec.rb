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

    it 'on an Array with Symbol elements it maps the Symbol to self' do
      expect(@obj.to_a :object_id).to eq [@obj.object_id]
    end

    it 'throws ArgumentError on all other types' do
      expect{@obj.to_a 1}.to raise_error ArgumentError
    end
  end
end
