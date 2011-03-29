require 'spec_helper'

require 'perl/interpreter'
require 'perl/value/hash'
require 'ffi'

class PerlCommon
  extend Perl::Common
end

describe Perl::Interpreter do
  describe "#initialize" do
    it "should call setup" do
      original_setup = Perl.setup
      Perl.should_receive(:setup) do
        @called = true
        original_setup
      end

      described_class.new
      @called.should be_true
    end

    it "should call perl_alloc and pass its return value to more methods" do
      Perl.should_receive(:perl_alloc).and_return(42)
      Perl.should_receive(:perl_construct).with(42)
      Perl.should_receive(:perl_parse) do |*args|
        @args = args
      end
      Perl.should_receive(:perl_run).with(42)

      described_class.new
      @args[0].should == 42
    end

    # XXX this is a bad spec, it should be a spec to fake_args itself
    it "should call perl_parse with the expected arguments" do
      argc, argv = PerlCommon.embedded_argv_to_ffi
      Perl.should_receive(:perl_parse) do |*args|
        @args = args
      end

      described_class.new
      @args[2].should == argc
      @args[3].should be_kind_of(FFI::MemoryPointer)
      @args[3].size.should == FFI.type_size(:pointer) * (argc + 1)

      (0..@args[2]).each do |i|
        entry = @args[3][i].get_pointer(0)
        entry.should be_kind_of(FFI::Pointer)
      end
      @args[3][0].get_pointer(0).read_string.should == ""
      @args[3][1].get_pointer(0).read_string.should == "-e"
      @args[3][2].get_pointer(0).read_string.should == "0"
      @args[3][3].get_pointer(0).address.should == 0
    end
  end

  describe "#call" do
    after(:each) do
      subject.stop
    end

    it "should prepare a Perl stack" do
      Perl::Stack.should_receive(:function_stack)

      subject.call("something", [], :void)
    end

    it "should call args_on_stack" do
      Perl::Stack::Function.should_receive(:new).any_number_of_times do |stack, args|
        @stack = stack
        @args = args
      end

      subject.call("something", [], :void)
      @args.should == []
      subject.call("something", [{}, :hash], :void)
      @args.should == [{}, :hash]
    end

    # XXX this should be a spec for Perl::Stack::Function
    # it "should push all the arguments onto the stack" do
    #   @stack = []
    # 
    #   fs = mock(:function_stack).tap do |stack|
    #     stack.should_receive(:push).any_number_of_times do |arg|
    #       @stack << arg
    #     end
    #   end
    #   Perl::Stack::Function.should_receive(:new).and_yield(fs)
    #   Perl.should_receive(:Perl_call_pv)
    # 
    #   subject.call("something", [{}, :hash], :void)
    #   @stack.length.should == 1
    #   @stack[0].should be_kind_of(FFI::Pointer)
    # end

    it "should pass a String to a Perl function" do
      func = subject.eval("require 'dumpvar.pl'; sub { dumpValue(\\@_); };")

      ret = capture_stdout_descriptor do
        subject.call(func, "42", :void)
      end
      ret = ret.split(/\n/)
      ret.length.should == 1
      ret[0].should =~ /^0\s+42/
    end

    it "should pass a String reference to a Perl function" do
      func = subject.eval("require 'dumpvar.pl'; sub { dumpValue(\\@_); };")

      ret = capture_stdout_descriptor do
        subject.call(func, {:ref => "42"}, :void)
      end
      ret = ret.split(/\n/)
      ret.length.should == 2
      ret[0].should =~ /^0\s+SCALAR/
      ret[1].should =~ /^\s+-> 42/
    end

    it "should pass a Hash reference to a Perl function" do
      func = subject.eval("require 'dumpvar.pl'; sub { dumpValue(\\@_); };")

      ret = capture_stdout_descriptor do
        subject.call(func, {:ref => {'a' => 'b'}}, :void)
      end
      ret = ret.split(/\n/)
      ret.length.should == 2
      ret[0].should =~ /^0\s+HASH/
      ret[1].should =~ /^\s+'a' => 'b'/
    end

    context "in a void context" do
      context "when passed a string" do
        it "should yield nil" do
          func = subject.eval("sub { return \"string\"; };")

          subject.call(func, [], :void) do |ret|
            ret.should be_nil
          end
        end

        it "the return value should be nil" do
          func = subject.eval("sub { return \"string\"; };")

          subject.call(func, [], :void).should be_nil
        end
      end

      context "when passed an array" do
        it "should yield nil" do
          func = subject.eval("sub { return [\"1\", \"2\"]; };")

          subject.call(func, [], :void) do |ret|
            ret.should be_nil
          end
        end

        it "the return value should be nil" do
          func = subject.eval("sub { return [\"1\", \"2\"]; };")

          subject.call(func, [], :void).should be_nil
        end
      end
    end

    context "in a scalar context" do
      context "when passed a string" do
        it "should yield a scalar that acts as a string" do
          func = subject.eval("sub { return \"string\"; };")

          subject.call(func, [], :scalar) do |ret|
            ret.value.should == "string"
          end
        end

        it "should return a scalar that acts as a string" do
          func = subject.eval("sub { return \"string\"; };")

          ret = subject.call(func, [], :scalar)
          ret.value.should == "string"
        end
      end

      context "when passed an array" do
        it "should yield an array reference" do
          func = subject.eval("sub { return [\"1\", \"2\"]; };")

          subject.call(func, [], :scalar) do |ret|
            ret.reference?.should be_true
            ret.deref.should be_kind_of(Perl::Value::Array)

            array = ret.deref.value
            array.length.should == 2
            array[0].should be_kind_of(Perl::Value::Scalar)
            array[0].value.should == "1"
            array[1].should be_kind_of(Perl::Value::Scalar)
            array[1].value.should == "2"
          end
        end

        it "the return value should be an array reference" do
          func = subject.eval("sub { return [\"1\", \"2\"]; };")

          ret = subject.call(func, [], :scalar)
          ret.reference?.should be_true
          ret.deref.should be_kind_of(Perl::Value::Array)

          array = ret.deref.value
          array.length.should == 2
          array[0].should be_kind_of(Perl::Value::Scalar)
          array[0].value.should == "1"
          array[1].should be_kind_of(Perl::Value::Scalar)
          array[1].value.should == "2"
        end
      end
    end
  end
end
