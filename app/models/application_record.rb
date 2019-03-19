class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def to_csv_row
    raise NotImplementedError, "Abstract method not implemented for #{self.class}"
  end
end
