require 'perl/value/hash'

class Hash
  #
  # Returns a pointer suitable for passing to Perl.
  #
  def to_perl
    Perl::Value::Hash.to_perl(self)
  end
end
