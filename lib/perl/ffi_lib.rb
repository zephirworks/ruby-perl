module Perl
  module FFILib
    def self.included(klass)
      klass.instance_eval do
        require 'perl/internal'
        extend FFI::Library

        Perl::FFILib::load(klass)

        # PERL_SYS_INIT3()
        attach_function 'Perl_sys_init3', [:int, :pointer, :pointer], :void
        # PERL_SYS_TERM()
        attach_function 'Perl_sys_term', [], :void

        klass.attach_function 'perl_alloc', [], :pointer
        attach_function 'perl_construct', [:pointer], :void
        # PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
        attach_function 'perl_parse', [:pointer, :pointer, :int, :pointer, :pointer], :void
        attach_function 'perl_run', [:pointer], :void
        attach_function 'perl_destruct', [:pointer], :void
        attach_function 'perl_free', [:pointer], :void

        # eval_pv()
        attach_function 'Perl_eval_pv', [:pointer, :string, :int], :pointer
        # call_pv()
        attach_function 'Perl_call_pv', [:pointer, :string, :int], :int
        # call_sv()
        attach_function 'Perl_call_sv', [:pointer, :pointer, :int], :int

        # ENTER()
        attach_function 'Perl_push_scope', [:pointer], :void
        # SAVETMPS()
        attach_function 'Perl_save_int', [:pointer, :pointer], :void
        # FREETMPS()
        attach_function 'Perl_free_tmps', [:pointer], :void
        # LEAVE()
        attach_function 'Perl_pop_scope', [:pointer], :void
        # PUSHMARK()
        attach_function 'Perl_markstack_grow', [:pointer], :void

        # newSV()
        attach_function 'Perl_newSVpv', [:pointer, :string, :int], :pointer

        attach_function 'Perl_newRV_noinc', [:pointer, :pointer], :pointer
        attach_function 'Perl_sv_2mortal', [:pointer, :pointer], :pointer

        attach_function 'Perl_newHV', [:pointer], :pointer
        # hv_store()
        attach_function 'Perl_hv_common_key_len', [:pointer, :pointer, :string, :int32, :int, :pointer, :uint32], :pointer

        attach_variable 'PL_curinterp', :pointer

        #
        # Returns a reference to internal information on the current
        # interpreter. Much of the public Perl API is in fact a thin
        # wrapper over data contained in here. A lot of damage can be
        # done my manipulating it incorrectly, so be careful.
        #
        def curinterp
          Perl::Internal.new(Perl.PL_curinterp)
        end
      end
    end

  private
    def self.load(klass)
      begin
        klass.ffi_lib Perl::FFILib::shlib
      rescue Exception
        klass.ffi_lib "/usr/lib/#{libperl}"
      end
    end

    def self.archlib
      `perl -MConfig -e 'print $Config{archlib}'`
    end

    def self.so_ext
      `perl -MConfig -e 'print $Config{so}'`
    end

    def self.libperl
      `perl -MConfig -e 'print $Config{libperl}'`
    end

    def self.shlib
      "#{archlib}/CORE/#{libperl}"
    end

  end
end
