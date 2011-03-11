require 'spec_helper'

require 'perl/value/hash'
require 'perl/interpreter'

describe Perl::Value::Hash do
  include PerlValueHelpers

  context "built without arguments" do
    its(:perl) { should_not be_nil }
    its(:hash) { should be_nil }
    its(:hv) { should be_nil }
  end

  context "built from a String" do
    let(:input) { "pippo" }
    it do
      lambda { described_class.new(input) }.should raise_error
    end
  end

  context "built from a Hash" do
    before(:all) do
      @interpreter = Perl::Interpreter.new
    end
    after(:all) do
      @interpreter.stop
    end

    let(:input) { {:a => "b", :c => "d"} }
    subject { described_class.new(input) }
    its(:perl) { should_not be_nil }
    its(:hash) { should_not be_nil }
    its(:hash) { should eq(input) }
    its(:hv) { should be_nil }

    describe "when #to_perl is called" do
      it "should return the expected object" do
        subject.to_perl.should_not be_nil
      end

      it "should cache the returned object" do
        subject.to_perl.should == subject.hv
      end
    end
  end
end
