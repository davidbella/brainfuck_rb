require 'spec_helper'
require_relative '../lib/brainfuck_rb/interpreter'

RSpec.describe Interpreter do
  subject { Interpreter.new(brainfuck_program) }
  let(:brainfuck_program) { '+++.' }

  describe 'VALID_BRAINFUCK_CHARS' do
    it 'contains an array of the 8 valid brainfuck characters [<>+-.,[]' do
      expect(Interpreter::VALID_BRAINFUCK_CHARS).to match_array([ '<', '>', '+', '-', '.', ',', '[', ']' ])
    end
  end

  describe '#array' do
    it 'is an array used for storage during program execution' do
      expect(subject.array).to be_an Array
    end

    it 'sets the first value at 0' do
      subject.array

      expect(subject.array[0]).to eq 0
    end
  end

  describe '#data_pointer' do
    it 'is an integer data pointer that starts at array position 0' do
      expect(subject.data_pointer).to eq 0
    end
  end

  describe '#instruction_pointer' do
    it 'tracks where in the brainfuck string the program is currently executing' do
      expect(subject.instruction_pointer).to eq 0
    end
  end

  describe '#execute!' do
    let(:brainfuck_program) { '+++-----' }

    it 'runs the expected command in the brainfuck program array' do
      expect(subject).to receive(:increment).exactly(3).times
      expect(subject).to receive(:decrement).exactly(5).times

      brainfuck_program.length.times { subject.execute! }
    end

    it 'increments the instruction pointer' do
      3.times { subject.execute! }
      expect(subject.instruction_pointer).to eq 3
    end

    context 'with a command that does not move the data pointer' do
      let(:brainfuck_program) { '.' }

      it 'will not move the data pointer' do
        expect(subject.data_pointer).to eq 0
        subject.execute!
        expect(subject.data_pointer).to eq 0
      end
    end

    describe 'commands' do
      context 'with a command that will increment the current data location' do
        let(:brainfuck_program) { '+' }

        it 'calls the increment command' do
          expect(subject).to receive(:increment)
          subject.execute!
        end
      end

      context 'with a command that will decrement the current data location' do
        let(:brainfuck_program) { '-' }

        it 'calls the decrement command' do
          expect(subject).to receive(:decrement)
          subject.execute!
        end
      end

      context 'with a command that will increment the data pointer' do
        let(:brainfuck_program) { '>' }

        it 'calls the increment_data_pointer command' do
          expect(subject).to receive(:increment_data_pointer)
          subject.execute!
        end
      end

      context 'with a command that will decrement the data pointer' do
        let(:brainfuck_program) { '<' }

        it 'calls the decrement_data_pointer command' do
          expect(subject).to receive(:decrement_data_pointer)
          subject.execute!
        end
      end

      context 'with a command that will print the current data location' do
        let(:brainfuck_program) { '.' }

        it 'calls the output command' do
          expect(subject).to receive(:output)
          subject.execute!
        end
      end

      context 'with a command that will read into the current data location' do
        let(:brainfuck_program) { ',' }

        it 'calls the input command' do
          expect(subject).to receive(:input)
          subject.execute!
        end
      end

      context 'with a command that may begin a loop' do
        let(:brainfuck_program) { '[]' }

        it 'calls the begin_loop command' do
          expect(subject).to receive(:begin_loop)
          subject.execute!
        end
      end

      context 'with a command that may end a loop' do
        let(:brainfuck_program) { '[]' }

        it 'calls the end_loop command' do
          allow(subject).to receive(:begin_loop)
          expect(subject).to receive(:end_loop)
          subject.execute!
          subject.execute!
        end
      end
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

  describe '#brainfuck_executable' do
    let(:brainfuck_program) { '+-.,[]<>' }

    it 'returns an array of all the interpretable characters in the input string' do
      expect(subject.brainfuck_executable).to match_array([ '+', '-', '.', ',', '[', ']', '<', '>' ])
    end
  end

  describe 'commands' do
    describe '.increment_data_pointer' do
      it 'adds one to the data pointer' do
        subject.increment_data_pointer

        expect(subject.data_pointer).to eq 1
      end

      it 'creates a default value at that place in the array of 0' do
        subject.increment_data_pointer

        expect(subject.array[subject.data_pointer]).to eq 0
      end

      it 'does not overwrite a place in the array that has already been visited' do
        subject.increment_data_pointer
        subject.increment
        subject.decrement_data_pointer
        subject.increment_data_pointer
        expect(subject.array[subject.data_pointer]).to eq 1
      end
    end


    describe '.decrement_data_pointer' do
      context 'when the data_pointer is at 0' do
         it 'will raise an ArrayOutOfBoundsException' do
           expect { subject.decrement_data_pointer }.to raise_error(ArrayOutOfBoundsException)
         end
      end

      it 'subtracts one from the data pointer' do
        5.times { subject.increment_data_pointer }

        expect(subject.decrement_data_pointer).to eq 4
        expect(subject.decrement_data_pointer).to eq 3
      end
    end


    describe '.increment' do
      it 'adds one to the first position in the array' do
        subject.increment
        expect(subject.array[subject.data_pointer]).to eq 1
      end

      it 'adds multiple times to the position in the array' do
        3.times { subject.increment }

        expect(subject.array[subject.data_pointer]).to eq 3
      end

      it 'adds one to the third position in the array when the data_pointer is pointing there' do
        2.times { subject.increment_data_pointer }

        subject.increment
        expect(subject.array[0]).to eq 0
        expect(subject.array[1]).to eq 0
        expect(subject.array[subject.data_pointer]).to eq 1
      end
    end


    describe '.decrement' do
      it 'subtracts one to first position in the array' do
        subject.decrement
        expect(subject.array[subject.data_pointer]).to eq(-1)
      end

      it 'subtracts multiple times to the position in the array' do
        3.times { subject.decrement }

        expect(subject.array[subject.data_pointer]).to eq(-3)
      end

      it 'subtracts one from the third position in the array when the data_pointer is pointing there' do
        2.times { subject.increment_data_pointer }

        subject.decrement
        expect(subject.array[0]).to eq 0
        expect(subject.array[1]).to eq 0
        expect(subject.array[subject.data_pointer]).to eq(-1)
      end
    end


    describe '.output' do
      it 'will print the character representation of the integer value at the current data_pointer' do
        65.times { subject.increment }

        expect(subject.output).to eq 'A'
      end
    end


    describe '.input' do
      it 'will store the integer representation of a character typed into standard input' do
        expect(STDIN).to receive(:gets) { 'A' }
        subject.input

        expect(subject.array[subject.data_pointer]).to eq 65
      end
    end


    describe '.begin_loop' do
      context 'with a zero at the current data_pointer' do
        it 'sets the instruction pointer to the matching end brace location' do
          expect_any_instance_of(BraceCalculator).to receive(:matching_end_brace).with(subject.instruction_pointer).and_return(5)
          subject.begin_loop
          expect(subject.instruction_pointer).to eq 5
        end
      end

      context 'with a positive integer at the current data_pointer' do
        it 'does nothing' do
          subject.increment
          subject.begin_loop
          expect(subject.instruction_pointer).to eq 0
        end
      end
    end


    describe '#end_loop' do
      context 'with a zero at the current data_pointer' do
        it 'does nothing' do
          subject.end_loop
          expect(subject.instruction_pointer).to eq 0
        end
      end

      context 'with a positive integer at the current data_pointer' do
        it 'sets the instruction pointer to the matching begin brace location' do
          expect_any_instance_of(BraceCalculator).to receive(:matching_begin_brace).with(subject.instruction_pointer).and_return(5)
          subject.increment
          subject.end_loop
          expect(subject.instruction_pointer).to eq 5
        end
      end
    end

  end

end
