require 'rails_helper'
require 'application_record'

RSpec.describe ApplicationRecord, type: :model do
  it 'should be an abstract class' do
    expect(ApplicationRecord.abstract_class).to be true
  end
end
