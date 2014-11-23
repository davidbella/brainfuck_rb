require_relative './brainfuck_rb/interpreter'

interpreter = Interpreter.new('+++.')
p interpreter.call
