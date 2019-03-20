require 'spec_helper'
require_relative '../../lib/assets/view'

RSpec.describe View do
  context '#initialize' do
    it 'raises TypeError on anything passed but ActiveRecord::Relation, DataLog, or Array' do
      expect{View.new Object}.to raise_error TypeError
    end

    it 'assigns arg1 to @collection when its an instance of ActiveRecord::Relation' do
      activerecord = Machine.all
      expect(View.new(activerecord).collection).to be activerecord
    end
  end

  context '#to_csv' do
    before :all do
      @filename = Rails.root.join 'tmp/view_csv.csv'
    end

    before :each do
      @machine = create :machine
    end
    
    it 'ActiveRecord::Relation by mapping &:to_csv_row' do
      machines = Machine.all
      view = View.new machines
      view.to_csv(@filename)

      # When the CSV is read back in, it'll be strings (except nils), so map &:to_s
      expected = [Machine.column_names, Machine.first.attributes.values.map {|i| i.nil? ? i : i.to_s}]
      expect(CSV.read(@filename)).to eq expected
    end
  end

  context 'private:' do
    context '#typecheck' do
      before :each do
        @obj = View.new []
      end

      it 'returns the arg if all items in arg are the same class as arg.first' do
        expect(@obj.send :typecheck, [1,1]).to eq [1,1]
      end

      it 'throws a TypeError otherwise' do
        expect{@obj.send :typecheck, [1,'']}.to raise_error TypeError
      end
    end

    context '#arrayify' do      
      context 'when @collection is ActiveRecord::Relation' do
        before :each do
          @machine = create :machine
          @view = View.new Machine.where id: @machine.id
        end

        it 'and !cols.nil?, it uses cols as the header, mapping send(col) over collection' do
          expect(@view.send :arrayify, ['id']).to eq [['id'], [@machine.id]]
        end

        it 'and cols.nil?, it defaults to the model schema' do
          # The timestamps need to be converted to dates because of millisecond diffs
          to_date = lambda {|i| i.is_a?(Time) ? i.to_date : i}

          expect(
            @view.send(:arrayify).flatten.map(&to_date)
          ).to(
            match_array (
                          Machine.column_names +
                          @machine.attributes.values.map(&to_date)
                        )
          )
        end
      end

      it 'does nothing when @collection is an Array' do
        expect(View.new(['a']).send :arrayify).to eq ['a']
      end
    end
  end
end
