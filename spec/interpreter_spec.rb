require 'spec_helper'
require_relative '../lib/brainfuck_rb/interpreter'

RSpec.describe Interpreter do
  subject { Interpreter.new(brainfuck_program) }

  describe 'VALID_BRAINFUCK_CHARS' do
    it 'contains an array of the 8 valid brainfuck characters [<>+-.,[]' do
      expect(Interpreter::VALID_BRAINFUCK_CHARS).to match_array([ '<', '>', '+', '-', '.', ',', '[', ']' ])
    end
  end

  describe '#interpretable_characters' do
    context 'with valid characters' do
      let(:brainfuck_program) { '+-.,[]<>' }

      it 'returns the valid, interpretable characters in the brainfuck program' do
        expect(subject.send(:interpretable_characters)).to eq brainfuck_program
      end
    end

    context 'with invalid characters' do
      let(:brainfuck_program) { 'g+-[dgg..dg.]dg<<fgdd<&&&' }
      let(:interpretable_brainfuck_program) { '+-[...]<<<' }

      it 'will not return any of the invalid characters' do
        expect(subject.send(:interpretable_characters)).to eq interpretable_brainfuck_program
      end
    end
  end
end
