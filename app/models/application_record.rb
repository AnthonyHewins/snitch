require Rails.root.join 'lib/assets/csv_morphable'

class ApplicationRecord < ActiveRecord::Base
  include CsvMorphable
  self.abstract_class = true

  def to_csv_row(procs_and_syms)
    procs_and_syms.map do |actionable|
      case actionable
      when Symbol
        self.attributes[actionable]
      when Proc
        actionable.call self
      else
        raise ArgumentError, "all elements in #to_csv_row must be sym or proc"
      end
    end
  end
end
