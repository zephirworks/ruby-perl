require 'spec_helper'

require 'perl/ext/hash'
require 'perl/interpreter'

describe Hash do
  describe "#to_perl" do
    before(:all) do
      @interpreter = Perl::Interpreter.new
    end
    after(:all) do
      @interpreter.stop
    end

    describe "on an empty Hash" do
      let(:subject) { {} }

      it "should return the expected result" do
        ptr = subject.to_perl
        ptr.should be_kind_of(FFI::Pointer)
      end
    end
  end
end