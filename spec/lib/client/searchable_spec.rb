require 'rails_helper'
require 'client/searchable'

RSpec.describe Searchable do
  before :all do
    @obj = Object.new
    @obj.extend Searchable
  end

  context 'protected:' do
    before :all do
      @array = %w(1 2 -1 -2 -5 01)
    end

    context 'find(collection, opts={}, &block)' do
      it 'on block.arity 1, finds the first instance satisfying block.call and values in opts' do
        expect(@obj.send :find, @array, length: 2, &lambda {|i| i.to_i < 0})
          .to eq '-1'
      end

      it 'on block.arity 2 calls filter_by_field then injects the block, making it the return value' do
        expect(@obj.send :find, @array, length: 2, &lambda {|i, j| 5}).to eq 5
      end

      it 'if block.nil?, find the first element satisfying the opts values' do
        expect(@obj.send :find, @array, to_i: 1).to eq '1'
      end

      it 'on all other arities, raises ArgumentError' do
        expect{@obj.send :find, [], &lambda {}}.to raise_error ArgumentError
      end
    end

    context 'filter(collection, opts={}, &block)' do
      it 'removes anything that doesnt match the opts values' do
        expect(@obj.send :filter, @array, {to_i: 1}).to eq %w(1 01)
      end

      it 'removes anything that doesnt match the opts and &block' do
        expect(@obj.send :filter, @array, {to_i: 1}, &lambda {|i| i.length == 2})
          .to eq %w(01)
      end
    end
  end

  context 'private:' do
    context 'filter_by_proc(collection, &block)' do
      it 'returns collection if block.nil?' do
        expect(@obj.send :filter_by_proc, []).to eq []
      end

      it 'when block.arity == 1 it uses Array#select to test for properties' do
        expect(@obj.send(:filter_by_proc, (0..10).to_a) {|i| i > 5})
          .to eq (6..10).to_a
      end

      it 'when block.arity == 2 it uses Array#inject to compare elements' do
        expect(@obj.send(:filter_by_proc, (0..10).to_a) {|i,j| i < j ? j : i})
          .to eq [10]
      end
    end

    context 'filter_by_fields(collection, opts)' do
      it 'can handle any unary operator as the key as long as collection.all?(&:respond_to?)' do
        collection = [0, '0', nil]
        query = {to_i: 0}
        expect(@obj.send :filter_by_fields, collection, query).to eq collection
      end

      it 'filters on all criteria given' do
        query = {length: 2, to_i: -1}
        expect(@obj.send :filter_by_fields, %w(01 -10 -1 -2), query).to eq %w(-1)
      end
    end

    context 'generate_select_syntax(opts)' do
      it 'returns [] if opts.empty?' do
        expect(@obj.send :generate_select_syntax, {}).to eq []
      end

      it 'maps keys with Regexp values to [[key, :match?, value]]' do
        expect(@obj.send :generate_select_syntax, {a: /a/}).to eq [[:a, :match?, /a/]]
      end

      it 'maps keys with non-Regexp values to [[key, :==, value]]' do
        expect(@obj.send :generate_select_syntax, {a: 1}).to eq [[:a, :==, 1]]
      end

      it 'using the two above cases, recursively performs this operation consuming all keys and zipping the results' do
        expect(@obj.send :generate_select_syntax, {a: 1, b: /a/})
          .to eq [[:a, :==, 1], [:b, :match?, /a/]]
      end
    end

    context 'satisfies_query?(element, [[:field, :operator, value], ...])' do
      it 'returns false unless all fields return true for element.send(field).send(operator, value)' do
        expect(@obj.send :satisfies_query?, 1, [[:to_s, :==, '1']]).to be true
      end
      it 'returns true if all fields return true for element.send(field).send(operator, value)' do
        expect(@obj.send :satisfies_query?, 1, [[:to_s, :!=, '1']]).to be false
      end
    end
    
    context 'determine_sensible_operators(array_of_matching_criteria)' do
      it 'returns :match? if a Regexp is given' do
        expect(@obj.send :determine_sensible_operators, [//]).to eq [:match?]
      end

      it 'returns :== for anything else' do
        expect(@obj.send :determine_sensible_operators, [1]).to eq [:==]
      end
    end
  end
end
