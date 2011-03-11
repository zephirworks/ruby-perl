require 'spec_helper'

require 'perl/ext/object'

class Object
  def perl_interpreter
    @_perl
  end
end

describe Object do
  after(:each) do
    perl_interpreter.stop
  end

  describe "#Perl" do
    it "should instance an interpreter" do
      perl_interpreter.should be_nil
      Perl("$_")
      perl_interpreter.should_not be_nil
      perl_interpreter.should be_kind_of(Perl::Interpreter)
    end

    # it "should run the provided code" do
    #   ret = capture_stdout_descriptor do
    #     Perl("print \"hi there\";")
    #   end
    #   ret.should == "hi there"
    # end
    # 
    # it "should run the provided code block" do
    #   ret = capture_stdout_descriptor do
    #     Perl do
    #       run "print \"hi there\";"
    #     end
    #   end
    #   ret.should == "hi there"
    # end
  end
end