class Perl::Stack::Function
  def initialize(stack, args, &block)
    @stack = stack
    @stack.dSP
    @stack.enter
    @stack.savetmps

    if args.any?
      begin
        @stack.pushmark
        Hash[[args]].each_pair do |arg, type|
          value = arg.to_perl
          value = Perl.Perl_newRV_noinc(Perl.PL_curinterp, value) if type == :ref

          push(value)
        end
      ensure
        @stack.putback
      end
    end

    yield(self)
  ensure
    if @stack
      @stack.freetmps
      @stack.leave
    end
  end

  def push(value)
    value = Perl.Perl_sv_2mortal(Perl.PL_curinterp, value)
    @stack.push(value)
  end

  def pop_scalar
    @stack.spagain
    return @stack.pops
  ensure
    @stack.putback
  end
end
