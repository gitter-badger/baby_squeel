require 'spec_helper'
require 'shared_examples/table'
require 'baby_squeel/dsl'

describe BabySqueel::DSL do
  subject(:dsl) {
    BabySqueel::DSL.new(Post)
  }

  it_behaves_like 'a table' do
    subject(:table) { dsl }
  end

  describe '#func' do
    it 'constructs a named function' do
      expect(dsl.func(:coalesce, 0, 1)).to produce_sql('coalesce(0, 1)')
    end
  end

  describe '#method_missing' do
    it 'resolves functions' do
      expect(dsl.coalesce(0, 1)).to be_a(Arel::Nodes::NamedFunction)
    end
  end

  describe '#evaluate' do
    context 'when an arity is given' do
      it 'yields itself' do
        dsl.evaluate do |table|
          expect(table).to be_a(BabySqueel::DSL)
        end
      end

      it 'does not change self' do
        this = self
        that = nil
        dsl.evaluate { |_t| that = self }
        expect(that).to equal(this)
      end
    end

    context 'when no arity is given' do
      it 'changes self' do
        this = self
        that = nil
        dsl.evaluate { that = self }
        expect(that).not_to equal(this)
      end

      it 'resolves attributes without a receiver' do
        resolution = nil
        dsl.evaluate { resolution = title }
        expect(resolution).to be_an(Arel::Attributes::Attribute)
      end
    end
  end
end
