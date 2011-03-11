module Perl
  class Internal < FFI::Struct
    class Stat < FFI::Struct
      size = 144
      layout  :a, :pointer
    end

    class Tms < FFI::Struct
      size = 32
      layout  :a, :pointer
    end

    class Jmpenv < FFI::Struct
      size = 168
      layout  :a, :pointer
    end

    layout  :Istack_sp,         :pointer,
            :Iopsave,           :pointer,
            :Icurpad,           :pointer,
            :Istack_base,       :pointer,
            :Istack_max,        :pointer,
            :Iscopestack,       :pointer,
            :Iscopestack_ix,    :int32,
            :Iscopestack_max,   :int32,
            :Isavestack,        :pointer,
            :Isavestack_ix,     :int32,
            :Isavestack_max,    :int32,
            :Itmps_stack,       :pointer,
            :Itmps_ix,          :int32,
            :Itmps_floor,       :int32,
            :Itmps_max,         :int32,
            :Imodcount,         :int32,
            :Imarkstack,        :pointer,
            :Imarkstack_ptr,    :pointer,
            :Imarkstack_max,    :pointer,
            :ISv,               :pointer,
            :IXpv,              :pointer,
            :Ina,               :int,
            :Istatbuf,          Stat,           # FIXME that's just wrong
            :Istatcache,        Stat,     288,  # FIXME that's just wrong
            :Istatgv,           :pointer, 432,
            :Istatname,         :pointer,
            :Itimesbuf,         Tms,            # FIXME that's just wrong
            :Icurpm,            :pointer, 480,
            :Irs,               :pointer,
            :Ilast_in_gv,       :pointer,
            :Iofs_sv,           :pointer,
            :Idefoutgv,         :pointer,
            :Ichopset,          :string,
            :Iformtarget,       :pointer,
            :Ibodytarget,       :pointer,
            :Itoptarget,        :pointer,
            :Idefstash,         :pointer,
            :Icurstash,         :pointer,
            :Irestartop,        :pointer,
            :Icurcop,           :pointer,
            :Icurstack,         :pointer,
            :Icurstackinfo,     :pointer,
            :Imainstack,        :pointer,
            :Itop_env,          :pointer,
            :Istart_env,        Jmpenv,         # FIXME that's just wrong
            :Ierrors,           :pointer, 784,
            :Ihv_fetch_ent_mh,  :pointer,
            :Ilastgotoprobe,    :pointer,
            :Isortcop,          :pointer,
            :Isortstash,        :pointer,
            :Ifirstgv,          :pointer,
            :Isecondgv,         :pointer,
            # TODO more stuff here
            :Iexit_flags,       :uint8,   1245
  end
end
