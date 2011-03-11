require 'perl/interpreter'

class Object
  #
  # Evaluate Perl code.
  #
  # You can provide the code as a String:
  #
  #    Perl 'print STDERR "hello world\n"'
  #
  # An alternative is to pass a block, which will be evaluated in the context
  # of a Perl::Interpreter instance. This means all Perl::Interpreter methods
  # will be available, so you can write:
  #
  #   Perl do
  #     load 'test.pl'
  #     eval 'sub { ... }'
  #     run 'print "hi there!\n";'
  #   end
  #
  def Perl(args = nil, &block)
    @_perl ||= Perl::Interpreter.new

    if args
      @_perl.eval(args)
    else
      @_perl.instance_eval(&block)
    end
  end
end
