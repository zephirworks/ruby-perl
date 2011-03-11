require 'perl/value'
require 'ffi'

class Perl::Value::Array
  class Av < FFI::Struct
    class Xnv_u < FFI::Union
      layout  :xnv_nv,        :long,
              :xgv_stash,     :pointer,
              :xpad_cop_seq,  :long,
              :xbm_s,         :long
    end

    layout  :xnv_u,     Xnv_u,
            :xav_fill,  :long,
            :xav_max,   :long

    def inspect
      "<#{self.class.name} @xav_fill=#{self[:xav_fill].inspect} @xav_max=#{self[:xav_max].inspect}>"
    end
  end

  def initialize(args)
    @perl = Perl.PL_curinterp
    @value = nil
    @array = nil
    @av = nil

    case args
    when Perl::Value::Scalar::SV
      @array = args[:sv_u][:svu_array]
      @av = Av.new(args[:sv_any])
    when nil
    else
      raise "Don't know how to handle #{args.class} (#{args.inspect})"
    end
  end

  def value
    return @value if @value
    if @array
      @value = @array.get_array_of_pointer(0, @av[:xav_fill]+1).map do |ptr|
        Perl::Value::Scalar.new(ptr)
      end
    else
      return nil
    end
  end

  def freeze!
    self.value.each { |v| v.freeze! }
    @array = nil
    @av = nil
  end
end
