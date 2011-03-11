module Perl; class Stack; end; end

require 'perl/stack/function'

module Perl
  class Stack
    class << self
      def function_stack(args, &block)
        Function.new(self.new, args, &block)
      end
    end

    def initialize
      @sp = nil
    end

    def dSP
      @sp = Perl.curinterp[:Istack_sp].tap { |sp| trace("dSP: @sp=#{sp}") }
    end
    alias_method :spagain, :dSP

    def enter
      Perl.Perl_push_scope(Perl.PL_curinterp)
    end

    def savetmps
      curinterp = Perl.curinterp
      trace("savetmps: curinterp=#{curinterp.to_ptr.inspect}")

      trace("savetmps: tmps_floor=#{curinterp[:Itmps_floor].inspect}")
      addr = Perl.PL_curinterp + curinterp.offset_of(:Itmps_floor)
      trace("addr=#{addr.inspect}")

      Perl.Perl_save_int(Perl.PL_curinterp, addr)
      trace("savetmps: tmps_floor now #{curinterp[:Itmps_floor].inspect}")

      trace("curinterp[:Itmps_ix] was #{curinterp[:Itmps_ix].inspect}")
      curinterp[:Itmps_floor] = curinterp[:Itmps_ix]
      trace("savetmps: tmps_floor now #{curinterp[:Itmps_floor].inspect}")
    end

    def pushmark
      trace("pushmark: @sp=#{@sp}")

      curinterp = Perl.curinterp
      trace("curinterp[:Imarkstack_ptr] was #{curinterp[:Imarkstack_ptr].inspect} == #{curinterp[:Imarkstack_max].inspect}")
      curinterp[:Imarkstack_ptr] += FFI.type_size(:int32)
      trace("curinterp[:Imarkstack_ptr] now #{curinterp[:Imarkstack_ptr].inspect}")
      if curinterp[:Imarkstack_ptr] == curinterp[:Imarkstack_max]
        Perl.Perl_markstack_grow(Perl.PL_curinterp)
      end
      trace("curinterp[:Imarkstack_ptr] <= #{@sp.address - curinterp[:Istack_base].address}")
      curinterp[:Imarkstack_ptr].put_pointer(0, @sp.address - curinterp[:Istack_base].address)
      trace("curinterp[:Imarkstack_ptr] now #{curinterp[:Imarkstack_ptr].inspect}")
    end

    def push(sv)
      trace("push: @sp=#{@sp}")
      @sp += FFI.type_size(:pointer)
      @sp.put_pointer(0, sv)
      trace("push: is now @sp=#{@sp}")
    end

    def putback
      trace("putback: @sp=#{@sp}")

      curinterp = Perl.curinterp
      curinterp[:Istack_sp] = @sp
    end

    def pops
      trace("pops: @sp=#{@sp}")

      ret = @sp.get_pointer(0)
      @sp = FFI::Pointer.new(@sp.address - FFI.type_size(:pointer))
      trace("pops: now @sp=#{@sp}")
      ret
    end

    def freetmps
      curinterp = Perl.curinterp
      trace("#{curinterp[:Itmps_ix].inspect} > #{curinterp[:Itmps_floor].inspect}")

      if curinterp[:Itmps_ix] > curinterp[:Itmps_floor]
        Perl.Perl_free_tmps(Perl.PL_curinterp)
        trace("#{curinterp[:Itmps_ix].inspect} > #{curinterp[:Itmps_floor].inspect}")
      end
    end

    def leave
      Perl.Perl_pop_scope(Perl.PL_curinterp)
    end

  protected
    def trace(msg)
      $stderr.puts(msg) if false
    end
  end
end
