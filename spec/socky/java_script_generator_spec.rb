require 'spec_helper'

begin
  require 'action_view'
  Socky::JavaScriptGenerator.send(:include, ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods)

  describe Socky do
    context "#send" do
      before(:each) do
        Socky.stub!(:send_data)
      end
      context "should normalize options" do
        it "when block given" do
          Socky.should_receive(:send_data).with({:command => :broadcast, :body => "test"})
          Socky.send do |page|
            page << "test"
          end
        end
      end
      context "with block" do
        it "should allow javascript helpers" do
          Socky.should_receive(:send_data).with({:command => :broadcast, :body => "alert(\"test!\");"})
          Socky.send do |page|
            page.alert("test!")
          end
        end
        it "should handle variables from current context" do
          phrase = "test phrase"
          Socky.should_receive(:send_data).with({:command => :broadcast, :body => phrase})
          Socky.send do |page|
            page << phrase
          end
        end
      end
    end
  
  end
  
rescue LoadError
  puts "ActionView unavailable - skipping"
end