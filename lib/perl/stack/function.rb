class Perl::Stack::Function
  def initialize(stack, args, &block)
    @stack = stack
    @stack.dSP
    @stack.enter
    @stack.savetmps

    case args
    when nil
      # nothing
    when Hash
      init_with_hash(args)
    else
      init_with_array(Array(args))
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

protected
  def init_with_hash(args)
    return unless args.any?

    begin
      @stack.pushmark
      args.each_pair do |type, arg|
        value = arg.to_perl
        value = Perl.Perl_newRV_noinc(Perl.PL_curinterp, value) if type == :ref
        push(value)
      end
    ensure
      @stack.putback
    end
  end

  def init_with_array(args)
    return unless args.any?

    args = Array(args)
    begin
      @stack.pushmark
      args.each do |arg|
        value = arg.to_perl
        push(value)
      end
    ensure
      @stack.putback
    end
  end
end
