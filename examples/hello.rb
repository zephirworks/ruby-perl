require 'perl'

# you can run a Perl program from a string...
Perl.run "print 'hello world!\n'"

# or better yet, a here-document
Perl <<-PERL
  ''=~('(?{'.('_/)@^['^'/]@.*{').'"'.('/+<][}}{|'^']^^${;),^').',$/})')
PERL
