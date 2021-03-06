require 'perl'
require 'perl/interpreter'

module Perl
  class Rack
    def initialize(filename)
      @interpreter = Perl::Interpreter.new
      @app = @interpreter.load(filename)
    end

    def call(env)
      @interpreter.call(@app, {:ref => clean_env(env)}, :scalar) do |ret|
        value = ret.deref.value # Array

        status = value[0].value

        v1 = value[1].deref.value
        headers = Hash[*v1.map { |v| v.value }]

        body = value[2].deref.value.map { |v| v.value }

        [status, headers, body]
      end
    rescue => e
      puts "e: #{e.inspect}\n#{e.backtrace.join("\n")}"
    end

    def clean_env(hash)
      ret = hash.dup
      if defined?(PhusionPassenger)
        ret = ret.reject do |k,v|
          v.is_a?(PhusionPassenger::Utils::RewindableInput)
        end
      end
      ret.tap do |h|
        ["async.close"].each do |k|
          if h.has_key?(k)
            puts "Cannot handle env['#{k}'] (#{k} => #{h[k].inspect}), skipping"
            h.delete("async.close")
          end
        end
      end
    end
  end
end
