require 'perl'
require 'perl/common'
require 'perl/stack'

module Perl
  class Interpreter
    include Perl::Common

    G_SCALAR  = 0
    G_ARRAY   = 1
    G_DISCARD = 2
    G_EVAL    = 4
    G_NOARGS  = 8
    G_KEEPERR = 16
    G_NODEBUG = 32
    G_METHOD  = 64
    G_VOID    = 128

    def initialize
      start
    end

    def eval(str=nil, &block)
      return Perl.Perl_eval_pv(Perl.PL_curinterp, str, 1) if str

      if block_given?
        yield(Statement.new)
      end
    end
    alias_method :run, :eval

    def load(filename)
      file = File.read(filename)
      eval(file)
    end

    def call(method_name, args, return_type)
      Perl::Stack.function_stack(args) do |stack|
        rc = do_call(method_name, options_for_call(args, return_type))
        ret = handle_return(rc, return_type, stack)

        if return_type == :void
          return nil
        else
          if block_given?
            return yield(ret)
          else
            ret.freeze!
            return ret
          end
        end
      end
    end

  protected
    def do_call(method_name, options)
      method = method_name.is_a?(String) ? :Perl_call_pv : :Perl_call_sv
      Perl.send(method, Perl.PL_curinterp, method_name, options)
    end

    # XXX should we have G_DISCARD ?
    def options_for_call(args, return_type)
      options = G_EVAL
      options |= G_NOARGS if args.empty?

      case return_type
      when :list
        options |= G_ARRAY
      when :scalar
        options |= G_SCALAR
      when :void
        options |= G_VOID
      else
        raise "Unknown return type #{return_type}"
      end
    end

    def handle_return(ret, return_type, stack)
      case return_type
      when :list
      when :scalar
        raise "Unexpected ret=#{ret}" unless ret == 1
        Perl::Value::Scalar.new(stack.pop_scalar)
      when :void
        raise "Unexpected ret=#{ret}" unless ret == 0
      end
    end
  end
end
