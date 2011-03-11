require 'perl/value'
require 'perl/value/scalar'
require 'ffi'

require 'stringio'

class Perl::Value::Hash
  HV_DISABLE_UVAR_XKEY  = 0x01
  HV_FETCH_ISSTORE      = 0x04
  HV_FETCH_ISEXISTS     = 0x08
  HV_FETCH_LVALUE       = 0x10
  HV_FETCH_JUST_SV      = 0x20
  HV_DELETE             = 0x40

  class << self
    def to_perl(hash)
      build_hv(Perl.PL_curinterp, hash)
    end

  protected
    def build_hv(perl, hash)
      new_hv(perl).tap do |hv|
        hash.each do |k,v|
          value = value_to_sv(k, v)
          add_key_value(perl, hv, k.to_s, value) if value
        end
      end
    end

    def new_hv(perl)
      Perl.Perl_newHV(perl)
    end

    def value_to_sv(key, value)
      case value
      when Array, IO
        puts "Don't know how to handle #{value.class} (#{key} => #{value.inspect})"
      when FalseClass
        Perl::Value::Scalar.to_perl(value.to_s) # FIXME
      when Method
        puts "Cannot handle value with class=#{value.class} (#{key} => #{value.inspect}), skipping"
      when String, StringIO
        Perl::Value::Scalar.to_perl(value)
      when TrueClass
        Perl::Value::Scalar.to_perl(value.to_s) # FIXME
      else
        raise "Don't know how to handle #{value.class} (#{key} => #{value.inspect})"
      end
    end

    def add_key_value(perl, hv, key, value)
      Perl.Perl_hv_common_key_len(perl, hv, key, key.length, (HV_FETCH_ISSTORE|HV_FETCH_JUST_SV), value, 0)
    end
  end

  def initialize(args = nil)
    @perl = Perl.PL_curinterp
    @hash = nil
    @hv = nil

    case args
    when Hash
      @hash = args
    when nil
    else
      raise "Don't know how to handle #{args.class} (#{args.inspect})"
    end
  end

  def to_perl
    @hv ||= self.class.send(:build_hv, @perl, @hash)
  end
end
