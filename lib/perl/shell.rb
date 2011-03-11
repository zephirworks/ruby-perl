require 'perl'
require 'perl/common'

module Perl
  class Shell
    include Perl::Common

    class << self
      def run
        new.run
      end
    end

    def initialize
      Perl.setup

      @my_perl = Perl.perl_alloc
      Perl.perl_construct(@my_perl)
    end

    def run
      argc, argv = argv_to_ffi

      Perl.perl_parse(@my_perl, nil, argc, argv, nil)
      Perl.perl_run(@my_perl)
    end
  end
end
