require 'spec_helper'

describe Socky::JSON do
  it "should respond to :decode method" do
    Socky::JSON.respond_to?(:decode).should be_true
  end
  it "should parse proper JSON to hash" do
    Socky::JSON.decode("{\"test\":\"passed\"}").should eql("test" => "passed")
  end
end