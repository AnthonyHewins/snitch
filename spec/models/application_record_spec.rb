require 'spec_helper'
require 'application_record'

RSpec.describe ApplicationRecord, type: :model do
  before :all do
    @concrete_class = Class.new
    @concrete_class.send :<, ApplicationRecord
  end
  
  it 'should be an abstract class' do
    expect(ApplicationRecord.abstract_class).to be true
  end

  it '#to_csv_row should be abstract (raises NoMethodError)' do
    expect {@concrete_class.new.to_csv_row}.to raise_error NoMethodError
  end
end
