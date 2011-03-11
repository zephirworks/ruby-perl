# require 'cover_me'
require 'pathname'
require 'tempfile'

module SpecHelper
  def root
    @root_path ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  def support
    root.join('spec', 'support')
  end

  module_function :root, :support
end

Dir["#{SpecHelper.support}/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
  config.mock_with :rspec
end

module Kernel
  def capture_stdout_descriptor
    Tempfile.open("spec") do |file|
      begin
        out = $stdout.dup
        $stdout.reopen(file)
        yield
        $stdout.flush
        return File.read(file)
      ensure
        $stdout.reopen(out)
      end
    end
  end
end
