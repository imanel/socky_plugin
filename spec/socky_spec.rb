require File.dirname(__FILE__) + '/spec_helper'  

describe Socky do
  it "should have config in hash form" do
    Socky::CONFIG.should_not be_nil
    Socky::CONFIG.class.should eql(Hash)
  end
  
  it "should have host list taken from config" do
    Socky.hosts.should eql(Socky::CONFIG[:hosts])
  end
  
  context "#send" do
    before(:each) do
      Socky.stub!(:send_data)
    end
    it "should send broadcast with data" do
      Socky.should_receive(:send_data).with({:command => :broadcast, :body => "test"})
      Socky.send("test")
    end
    context "should normalize options" do
      it "when no data given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :body => ""})
        Socky.send
      end
      it "when string given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :body => "test"})
        Socky.send("test")
      end
      it "when block given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :body => "test"})
        Socky.send do |page|
          page << "test"
        end
      end
    end
  end
  
  context "#show_connections" do
    before(:each) do
      Socky.stub!(:send_data)
    end
    it "should send query :show_connections" do
      Socky.should_receive(:send_data).with({:command => :query, :type => :show_connections}, true)
      Socky.show_connections
    end
  end
  
end