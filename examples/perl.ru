$: << 'lib'
require 'perl/rack'

run Perl::Rack.new("examples/webapp.psgi")
