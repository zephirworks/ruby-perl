require 'spec_helper'

require 'perl/ext/string'
require 'perl/interpreter'

describe String do
  describe "#to_perl" do
    before(:all) do
      @interpreter = Perl::Interpreter.new
    end
    after(:all) do
      @interpreter.stop
    end

    describe "on an empty String" do
      let(:subject) { "" }

      it "should return the expected result" do
        ptr = subject.to_perl
        ptr.should be_kind_of(FFI::Pointer)
        value = Perl::Value::Scalar.new(ptr)
        value.value.should == ""
      end
    end

    describe "on a String" do
      let(:subject) { "something" }

      it "should return the expected result" do
        ptr = subject.to_perl
        ptr.should be_kind_of(FFI::Pointer)
        value = Perl::Value::Scalar.new(ptr)
        value.value.should == "something"
      end
    end
  end
end