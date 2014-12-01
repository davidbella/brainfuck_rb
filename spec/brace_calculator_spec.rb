require 'spec_helper'
require_relative '../lib/brainfuck_rb/brace_calculator'

RSpec.describe BraceCalculator do
  subject { BraceCalculator.new(brainfuck_program) }

  describe '#matching_braces' do
    context 'no loops in the brainfuck program' do
      let(:brainfuck_program) { '++++--+><><'.chars }

      it 'does not have any matching_braces' do
        expect(subject.matching_braces).to be_empty
      end
    end

    context 'with one, non-embedded set of braces' do
      let(:brainfuck_program) { '+-[...]-+'.chars }

      it 'adds a brace set to the hash of matching braces' do
        expect(subject.matching_braces).to_not be_empty
      end

      it 'adds the brace set with the correct indices' do
        expect(subject.matching_braces).to include({ 2 => 6 })
      end
    end

    context 'with an embedded set of braces' do
      let(:brainfuck_program) { '+-[..[..]..]-+'.chars }

      it 'adds two brace sets to the hash of matching braces' do
        expect(subject.matching_braces.count).to eq 2
      end

      it 'adds the brace sets with the correct indices' do
        expect(subject.matching_braces).to include({ 2 => 11 })
        expect(subject.matching_braces).to include({ 5 => 8 })
      end
    end
  end

  describe '#matching_end_brace' do
    let(:brainfuck_program) { '+-[...]-+'.chars }

    it 'returns the matching end brace for a given instruction pointer location' do
      expect(subject.matching_end_brace(2)).to eq 6
    end

    it 'raises an error when there is no entry for the beginning brace location' do
      expect { subject.matching_end_brace(3) }.to raise_error KeyError
    end
  end

  describe '#matching_begin_brace' do
    let(:brainfuck_program) { '+-[...]-+'.chars }

    it 'returns the matching begin brace for a given instruction pointer location' do
      expect(subject.matching_begin_brace(6)).to eq 2
    end
  end
end
