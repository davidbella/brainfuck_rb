require_relative './brace_calculator'

class ArrayOutOfBoundsException < Exception; end

class Interpreter
  VALID_BRAINFUCK_CHARS = [ '<', '>', '+', '-', '.', ',', '[', ']' ]
  attr_reader :data_pointer, :instruction_pointer

  def initialize(program_string)
    @program_string = program_string
    @data_pointer = 0
    @instruction_pointer = 0
    @brace_calculator = BraceCalculator.new(brainfuck_executable)
  end

  def call
    while @instruction_pointer < brainfuck_executable.length
      execute!
    end
  end

  def execute!
    case brainfuck_executable[instruction_pointer]
      when '+'
        increment
      when '-'
        decrement
      when '>'
        increment_data_pointer
      when '<'
        decrement_data_pointer
      when '.'
        output
      when ','
        input
      when '['
        begin_loop
      when ']'
        end_loop
    end

    @instruction_pointer += 1
  end

  def brainfuck_executable
    @brainfuck_executable ||= interpretable_characters.chars
  end

  def array
    @array ||= Array.new << 0
  end

  def increment_data_pointer
    @data_pointer += 1
    array[@data_pointer] ||= 0
  end

  def decrement_data_pointer
    raise ArrayOutOfBoundsException if @data_pointer == 0
    @data_pointer -= 1
  end

  def increment
    array[@data_pointer] += 1
  end

  def decrement
    array[@data_pointer] -= 1
  end

  def output
    print array[@data_pointer].chr
    array[@data_pointer].chr
  end

  def input
    array[@data_pointer] = 0 # WRITE A TEST FOR ME, THIS BROKE
    STDIN.gets.chomp.ord.times { increment }
  end

  def begin_loop
    if array[@data_pointer] == 0
      @instruction_pointer = @brace_calculator.matching_end_brace(@instruction_pointer)
    end
  end

  def end_loop
    if array[@data_pointer] != 0
      @instruction_pointer = @brace_calculator.matching_begin_brace(@instruction_pointer)
    end
  end

  private

    def interpretable_characters
      @program_string.each_char.select do |c|
        VALID_BRAINFUCK_CHARS.include?(c)
      end.join
    end
end
