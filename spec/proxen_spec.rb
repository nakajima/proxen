require 'spec/spec_helper'
require 'ostruct'

describe Proxen do
  it "proxies method_missing to method" do
    @klass = Class.new do
      proxy_to :foo
      
      def foo
        Class.new { def bar; :proxied end }.new
      end
    end
    
    @klass.new.bar.should == :proxied
  end
  
  it "respects other method missings" do
    @klass = Class.new do
      proxy_to :foo
      
      def foo
        Class.new { def bar; :proxied end }.new
      end
      
      def method_missing(sym, *args, &block)
        :not_proxied
      end
    end
    
    @klass.new.bar.should == :not_proxied
  end
  
  it "can generate blank slates" do
    @klass = Class.new do
      proxy_to :foo, :blank_slate => true
      
      def foo
        Class.new { def inspect; :proxied end }.new
      end
    end
    
    @klass.new.inspect.should == :proxied
  end
  
  it "accepts regexen" do
    @klass = Class.new do
      proxy_to :foo, :if => /zz/
      
      def foo
        Class.new {
          def baz; :err end
          def fizz; :proxied end
          def buzz; :proxied end
        }.new
      end
    end
    
    @klass.new.fizz.should == :proxied
    @klass.new.buzz.should == :proxied
    
    proc {
      @klass.new.baz.should == :proxied
    }.should raise_error(NoMethodError)
  end
end