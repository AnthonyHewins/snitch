require 'csv'

module CsvMorphable
  def to_a(*procs_or_syms)
    procs_or_syms.map do |actionable|
      case actionable
      when Symbol
        self.send actionable
      when Proc
        actionable.call self
      else
        raise ArgumentError, "#to_a only accepts Proc and Symbols"
      end
    end
  end
end
