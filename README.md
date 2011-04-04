ruby-perl
=========

    Ruby and Perl, sitting in a tree K-I-S-S-I-N-G

For rubyists:
-------------

ruby-perl lets you evaluate and run Perl code within the same binary, without
any heavy-weight forking of sub-processes. Enjoy the compactness, robustness
and maintainability of Perl!

For perlists:
-------------

Run your Perl application over industry-standard, enterprise-grade MRI Ruby,
Rack and Passenger!

Background story
----------------

Check out our announce [blog post](http://blog.zephirworks.com/47768566) for the story behind this.

Getting started
===============

On the command line
-------------------

Install the gem:

    gem install ruby-perl

Run a Perl program:

    rperl examples/hello.pl

Or play around in the Perl interactive shell:

    rperl -de 0

Web applications
----------------

You can run your Perl webapp with Rack using the provided Rack adapter:

    thin -R examples/perl.ru

ruby-perl supports [PSGI](http://search.cpan.org/~miyagawa/PSGI-1.03/PSGI.pod)
(Perl Web Server Gateway Interface Specification); as such it can run any
webapp written in any conforming framework, such as
[Mason](http://www.masonhq.com/).

However, for the time you have to provide your own Rackup file. Luckily a
typical Rackup file for ruby-perl is fairly simple (just take a look at
[examples/perl.ru](examples/perl.ru) in the repository), and it boils down to:

    run Perl::Rack.new("examples/webapp.psgi")

ruby-perl has been developed with [Thin](http://code.macournoyer.com/thin/)
in mind, but since [Phusion Passenger](http://www.modrails.com/) is 100%
compatible with Rack, you can use it too: just stick a config.ru file in your
document root (together with the mandatory public/ and tmp/ subdirectories)
and you are ready to go. Read The Fine [Passenger Manual](http://www.modrails.com/documentation/Users%20guide%20Apache.html#_deploying_a_rack_based_ruby_application)
for more info.

In your own application: evaluating Perl code
---------------------------------------------

You can embed Perl code directly in your Ruby application in a nice and
friendly way:

    require 'perl'
    
    def foo(arg)
      Perl.run %Q{$_=#{arg};(1x$_)!~/^1?$|^(11+?)\\1+$/&&print"$_\n"}
    end
    
    foo(42)
    foo(13)

For additional eye-candy, more styles are supported:

    Perl <<-PERL
      return 0 if $_[0] =~ 
      /(?:[\.\-\_]{2,})|(?:@[\.\-\_])|(?:[\.\-\_]@)|(?:\A\.)/;
      return 1 if $_[0] =~ 
      /^[\w\.\-\_]+\@\[?[\w\.\-\_]+\.(?:[\w\.\-\_]{2,}|[0-9])\]?$/;
      return 0;
    PERL

or:

    Perl do
      run <<-PERL
        my @sorted_ips = #sort by ip
          map substr($_, 4) =>
            sort map pack('C4' =>
              split /\./)
                . $_ => (@unsorted_ips);
      PERL
    end

Embedded Perl however has a some pretty big limitation, the biggest being
that you cannot easily pass data from Ruby to Perl and vice-versa, except
by string interpolation as shown in the first example.

In your own application: invoking Perl code
-------------------------------------------

ruby-perl lets you invoke arbitrary Perl code you have loaded or evaluated.
In other words, you can implement some functionality in Perl and seamlessly
call it from Ruby:

    require 'perl'
    
    Perl do
      @func = eval %Q{sub { $arg = shift; print "You said: $arg\n"; };}
      
      ...
      
      call @func, "42", :scalar
    end

In the previous snippet we first define a Perl `sub` and we assign it to
the `@func` instance variable; we then call it passing a String. For all
intents and purposes, `@func` is now a lambda you can pass around and call,
only it's implemented in Perl.

Contributors
============

* Andrea Campi (@andreacampi)
* Chris Weyl (@RsrchBoy)

Bug reports
===========

ruby-perl is rather well test with RSpec, however you may still find a few
bugs. Please report them any [issue](https://github.com/zephirworks/ruby-perl/issues)
you may find.

Copyright and license
=====================

Copyright (c) 2011 ZephirWorks.
This code is released under the MIT license.
