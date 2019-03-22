require 'rails_helper'
require Rails.root.join 'app/models/application_record'

RSpec.describe ApplicationRecord, type: :model do
  before :all do
    @concrete_class = Class.new
    @concrete_class.send :<, ApplicationRecord
  end

  it 'should be an abstract class' do
    expect(ApplicationRecord.abstract_class).to be true
  end
end
