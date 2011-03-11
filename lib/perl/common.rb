module Perl
  module Common
    PERL_EXIT_EXPECTED      = 0x01
    PERL_EXIT_DESTRUCT_END  = 0x02

    def start
      Perl.setup
      argc, argv = embedded_argv_to_ffi

      @my_perl = Perl.perl_alloc
      Perl.perl_construct(@my_perl)

      Perl.curinterp[:Iexit_flags] |= PERL_EXIT_DESTRUCT_END

      Perl.perl_parse(@my_perl, nil, argc, argv, nil)
      Perl.perl_run(@my_perl)
    end

    def stop
      Perl.perl_destruct(@my_perl)
      Perl.perl_free(@my_perl)

      @my_perl = nil
      Perl.PL_curinterp = nil
    end

    #
    # Returns a C-style tuple of <argc,argv> corresponding to the real
    # arguments the application was invoked with.
    #
    def argv_to_ffi
      array_to_ffi(ARGV)
    end

    #
    # Returns a C-style tuple of <argc,argv> suitable for running an
    # embedded Perl interpreter.
    #
    def embedded_argv_to_ffi
      array_to_ffi(%w[-e 0])
    end

  protected
    def array_to_ffi(array)
      strptrs = [].tap do |ptrs|
        ptrs << FFI::MemoryPointer.from_string("")  # XXX
        array.each do |arg|
          ptrs << FFI::MemoryPointer.from_string(arg)
        end
        ptrs << nil
      end

      [strptrs.length-1, array_ptr(strptrs)]
    end

    def array_ptr(list)
      FFI::MemoryPointer.new(:pointer, list.length).tap do |argv|
        list.each_with_index do |p, i|
          argv[i].put_pointer(0,  p)
        end
      end
    end
  end
end
