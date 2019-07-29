require 'csv_morphable'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include CsvMorphable
end
