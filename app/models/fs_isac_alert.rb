class FsIsacAlert < ApplicationRecord
  CsvColumns = FsIsacAlert.column_names.map &:to_sym

  validates :tracking_id,
            uniqueness: true,
            presence: true,
            inclusion: {in: 1..2147483647}

  %i(
       title
       alert
       affected_products
       corrective_action
       sources 
       alert_timestamp
  ).each do |sym|
    validates_presence_of sym
  end
  
  before_save do |record|
    %i(title alert affected_products corrective_action sources).each do |sym|
      record.send(sym).squish!.gsub!(",", '')
    end
  end

  def to_a(*cols)
    cols.empty? ? super(*CsvColumns) : super(*cols)
  end
end
