require 'rubygems'
require 'ffi'

require 'perl/ffi_lib'
require 'perl/common'
require 'perl/interpreter'

module Perl
  include Perl::FFILib
  extend Perl::Common

  @initialized = false
  @mutex = Mutex.new

  def setup
    @mutex.synchronize do
      return if @initialized

      argc, argv = argv_to_ffi

      Perl.Perl_sys_init3(argc, argv, nil)

      at_exit { shutdown }
      @initialized = true
    end
  end
  module_function :setup

  def shutdown
    Perl.Perl_sys_term
    @initialized = false
  end
  module_function :shutdown

  def run(args)
    Interpreter.new.eval(args)
  end
  module_function :run
end

require 'perl/ext/hash'
require 'perl/ext/object'
require 'perl/ext/string'
