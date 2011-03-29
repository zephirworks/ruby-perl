Gem::Specification.new do |s|
  s.name = %q{ruby-perl}
  s.version = "0.99.15j"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6")
  s.rubygems_version = %q{1.3.6}
  s.authors = ["Andrea Campi"]
  s.date = %q{2011-04-01}
  s.summary = %q{Run Perl code from any Ruby application.}
  s.description = %q{Run Perl code from any Ruby application, or run Perl web apps on Ruby.}
  s.email = %w{andrea.campi@zephirworks.com}
  s.homepage = %q{http://github.com/zephirworks/ruby-perl}
  s.rubyforge_project = %q{ruby-perl}
  s.has_rdoc = false
  s.files = [
    ".autotest",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "Rakefile",
    "autotest/discover.rb",
    "bin/rperl",
    "examples/hello.pl",
    "examples/hello.rb",
    "examples/hello_block.rb",
    "examples/hello_here.rb",
    "examples/perl.ru",
    "examples/webapp.psgi",
    "lib/perl.rb",
    "lib/perl/common.rb",
    "lib/perl/ext/hash.rb",
    "lib/perl/ext/object.rb",
    "lib/perl/ext/string.rb",
    "lib/perl/ffi_lib.rb",
    "lib/perl/internal.rb",
    "lib/perl/interpreter.rb",
    "lib/perl/rack.rb",
    "lib/perl/shell.rb",
    "lib/perl/stack.rb",
    "lib/perl/stack/function.rb",
    "lib/perl/value.rb",
    "lib/perl/value/array.rb",
    "lib/perl/value/hash.rb",
    "lib/perl/value/scalar.rb",
    "spec/ext/hash_spec.rb",
    "spec/ext/object_spec.rb",
    "spec/ext/string_spec.rb",
    "spec/hash_value_spec.rb",
    "spec/interpreter_spec.rb",
    "spec/scalar_value_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/perl_value_helpers.rb",
  ]
  s.require_paths = ["lib"]
  s.bindir = "bin"
  s.executables << "rperl"
  s.add_dependency(%q<ffi>, ["~> 1.0.6"])
end