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

  it "accepts :if regexen" do
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

  it "accepts :unless regexen" do
    @klass = Class.new do
      proxy_to :foo, :unless => /zz/

      def foo
        Class.new {
          def baz; :proxied end
          def fizz; :err end
          def buzz; :err end
        }.new
      end
    end

    @klass.new.baz.should == :proxied

    proc {
      @klass.new.fizz
      @klass.new.buzz
    }.should raise_error(NoMethodError)
  end

  it "proxies to multiple" do
    @klass = Class.new do
      proxy_to :foo, :bar

      def foo
        Class.new { def fizz; :proxied end }.new
      end

      def bar
        Class.new { def buzz; :proxied end }.new
      end
    end

    @klass.new.fizz.should == :proxied
    @klass.new.buzz.should == :proxied
  end
end
