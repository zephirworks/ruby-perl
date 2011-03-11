module PerlValueHelpers
  def self.included(klass)
    require 'perl/value'

    Perl::Value::Hash.class_eval do
      attr_reader :perl, :hash, :hv
    end

    Perl::Value::Scalar.class_eval do
      attr_reader :perl, :scalar, :sv
    end
  end
end
