require 'application_record'

class Department < ApplicationRecord
  CsvColumns = Department.column_names

  has_many :machines, dependent: :restrict_with_exception
end
