class Interpreter
  VALID_BRAINFUCK_CHARS = [ '<', '>', '+', '-', '.', ',', '[', ']' ]

  def initialize(program_string)
    @program_string = program_string
  end

  private

    def interpretable_characters
      @program_string.each_char.select do |c|
        VALID_BRAINFUCK_CHARS.include?(c)
      end.join
    end
end
