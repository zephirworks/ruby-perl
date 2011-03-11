require 'spec_helper'

require 'perl/interpreter'
require 'perl/value/scalar'

describe Perl::Value::Scalar do
  include PerlValueHelpers

  before(:all) do
    @interpreter = Perl::Interpreter.new
  end
  after(:all) do
    @interpreter.stop
  end

  describe "class method" do
    describe " #to_perl" do
      it "should return the expected object when passed a String" do
        input = "something"

        sv = described_class.to_perl(input)
        sv.should_not be_nil

        ret = described_class.new(sv)
        ret.should_not be_nil
        ret.value.should eq(input)
      end

      it "should return the expected object when passed a StringIO" do
        input = StringIO.new("something")

        sv = described_class.to_perl(input)
        sv.should_not be_nil

        ret = described_class.new(sv)
        ret.should_not be_nil
        ret.value.should eq(input.string)
      end

      it "should raise when passed a Fixnum" do
        lambda { described_class.to_perl(42) }.should raise_error
      end
    end
  end

  context "built without arguments" do
    its(:perl) { should_not be_nil }
    its(:scalar) { should be_nil }
    its(:sv) { should be_nil }
  end

  context "built from a Fixnum" do
    let(:input) { 42 }
    it do
      lambda { described_class.new(input) }.should raise_error
    end
  end

  context "built from a String" do
    let(:input) { "something" }
    subject { described_class.new(input) }
    its(:perl) { should_not be_nil }
    its(:scalar) { should_not be_nil }
    its(:scalar) { should eq(input) }
    its(:sv) { should be_nil }

    describe "when #to_perl is called" do
      it "should return the expected object" do
        sv = subject.to_perl
        sv.should_not be_nil

        ret = described_class.new(sv)
        ret.should_not be_nil
        ret.value.should eq(input)
      end

      it "should cache the returned object" do
        subject.to_perl.should == subject.sv
      end
    end
  end
end
