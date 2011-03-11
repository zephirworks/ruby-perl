require 'perl/value/scalar'

class String
  #
  # Returns a pointer suitable for passing to Perl.
  #
  def to_perl
    Perl::Value::Scalar.to_perl(self)
  end
end
