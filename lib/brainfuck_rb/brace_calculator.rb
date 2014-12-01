class BraceCalculator
  attr_reader :matching_braces

  def initialize(brainfuck_program)
    @matching_braces = {}

    load_matching_braces(brainfuck_program)
  end

  def matching_end_brace(instruction_pointer)
    @matching_braces.fetch(instruction_pointer)
  end

  def matching_begin_brace(instruction_pointer)
    @matching_braces.key(instruction_pointer)
  end

  private

    def load_matching_braces(brainfuck_program)
      brainfuck_program.each_with_index do |char, index|
        if char == '['
          end_index = find_matching_end_brace(brainfuck_program[index..-1])
          @matching_braces.merge!({ index => index + end_index })
        end
      end
    end

    def find_matching_end_brace(remaining_program)
      brace_counter = 0

      remaining_program.each_with_index do |char, index|
        if char == '['
          brace_counter += 1
        end

        if char == ']'
          brace_counter -= 1
          return index if brace_counter == 0
        end
      end
    end
end
