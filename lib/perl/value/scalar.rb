require 'perl/value'
require 'perl/value/array'
require 'ffi'

class Perl::Value::Scalar
  class SV < FFI::Struct
    class SvU < FFI::Union
      layout  :svu_iv,    :long,
              :svu_uv,    :long, # XXX ?
              :svu_rv,    :pointer,
              :svu_pv,    :string,
              :svu_array, :pointer,
              :svu_hash,  :pointer,
              :svu_gp,    :pointer
    end

    layout  :sv_any,    :pointer,
            :sv_refcnt, :int32,
            :sv_flags,  :int32,
            :sv_u,      SvU

    SVt_NULL    = 0
    SVt_BIND    = 1
    SVt_IV      = 2
    SVt_NV      = 3
    SVt_RV      = 4
    SVt_PV      = 5
    SVt_PVIV    = 6
    SVt_PVNV    = 7
    SVt_PVMG    = 8
    SVt_PVGV    = 9
    SVt_PVLV    = 10
    SVt_PVAV    = 11
    SVt_PVHV    = 12
    SVt_PVCV    = 13
    SVt_PVFM    = 14
    SVt_PVIO    = 15
    SVTYPEMASK  = 0xff

    SVf_IOK = 0x00000100
    SVf_NOK = 0x00000200
    SVf_POK = 0x00000400
    SVf_ROK = 0x00000800

    def value
      case
      when (self[:sv_flags] & SVf_POK) == SVf_POK
        self[:sv_u][:svu_pv]
      when (self[:sv_flags] & SVf_ROK) == SVf_ROK
        Perl::Value::Scalar.new(self[:sv_u][:svu_rv])
      when (self[:sv_flags] & SVTYPEMASK) == SVt_PVAV
        Perl::Value::Array.new(self)
      else
        raise "Don't know how to handle #{self[:sv_u]} (#{self.inspect})"
      end
    end

    def reference?
      (self[:sv_flags] & SVf_ROK) == SVf_ROK
    end

    def deref
      raise "Not a reference!" unless (self[:sv_flags] & SVf_ROK) == SVf_ROK

      SV.new(self[:sv_u][:svu_rv]).value
    end

    def inspect
      "<#{self.class.name} @pointer=#{self.pointer} @sv_any=#{self[:sv_any].inspect} @sv_refcnt=#{self[:sv_refcnt].inspect} @sv_flags=0x#{self[:sv_flags].to_s(16)} @sv_u=#{self[:sv_u].inspect}>"
    end
  end

  class << self
    def to_perl(value)
      case value
      when String
        Perl.Perl_newSVpv(Perl.PL_curinterp, value, value.length)
      when StringIO
        value = value.string
        Perl.Perl_newSVpv(Perl.PL_curinterp, value, value.length)
      when nil
      else
        raise "Don't know how to handle #{value.class} (#{value.inspect})"
      end
    end
  end

  def initialize(args = nil)
    @perl = Perl.PL_curinterp
    @scalar = nil
    @sv = nil
    @deref = nil
    @is_ref = nil

    case args
    when FFI::Pointer
      @sv = SV.new(args)
    when String
      @scalar = args
    when nil
    else
      raise "Don't know how to handle #{args.class} (#{args.inspect})"
    end
  end

  def to_perl
    @sv ||= Perl.Perl_newSVpv(@perl, @scalar, @scalar.length)
  end

  def value
    @scalar ||= @sv ? @sv.value : nil
  end

  def reference?
    if @is_ref.nil?
      @is_ref = @sv.reference?
    else
      @is_ref
    end
  end

  def deref
    @deref ||= to_perl.deref
  end

  def freeze!
    reference? ? self.deref.freeze! : self.value
    @sv = nil
  end
end
