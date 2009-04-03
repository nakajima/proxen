module Proxen
  class Proxy
    class << self
      def add(klass, *args)
        store[klass] = new(klass, *args)
      end

      def handle(instance, sym, *args, &block)
        klass = Object.instance_method(:class).bind(instance).call
        if proxy = store[klass]
          proxy.handle(instance, sym, *args, &block)
        end
      end

      private

      def store
        @store ||= {}
      end
    end

    def initialize(klass, *args)
      @klass = klass
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @targets = Array(args).flatten

      blankify! if @options[:blank_slate]
    end

    def handle(instance, sym, *args, &block)
      if target = target_for(instance, sym)
        if @options[:compile]
          compile(target, sym)
          instance.__send__(sym, *args, &block)
        else
          instance.__send__(target).__send__(sym, *args, &block)
        end
      end
    end

    def blankify!
      @klass.class_eval do
        instance_methods.each do |sym|
          undef_method(sym) unless sym.to_s =~ /__/
        end
      end
    end

    private
    
    def compile(receiver, sym)
      @klass.class_eval(<<-END, __FILE__, __LINE__)
        def #{sym}(*args, &block)
          #{receiver}.send(#{sym.inspect}, *args, &block)
        end
      END
    end

    def proxying?(instance, sym)
      case @options[:if] || @options[:unless]
      when Proc   then calls?(sym)
      when Regexp then match?(sym)
      when Symbol then sends?(instance, sym)
      else true
      end
    end

    def calls?(sym)
      case
      when fn = @options[:if]      then fn.call(sym)
      when fn = @options[:unless]  then not fn.call(sym)
      end
    end

    def sends?(instance, sym)
      case
      when cond = @options[:if]      then instance.__send__(cond, sym)
      when cond = @options[:unless]  then not instance.__send__(cond, sym)
      end
    end

    def match?(sym)
      case
      when regex = @options[:if]      then sym.to_s =~ regex
      when regex = @options[:unless]  then not sym.to_s =~ regex
      end
    end

    def target_for(instance, sym)
      return nil unless proxying?(instance, sym)
      @targets.detect { |t| instance.__send__(t).respond_to?(sym) }
    end
  end

  def proxy_to(*targets)
    Proxen::Proxy.add(self, *targets)

    class_eval(<<-END, __FILE__, __LINE__)
      def method_missing(sym, *args, &block)
        Proxen::Proxy.handle(self, sym, *args, &block) || super
      end
    END
  end
end

Class.send :include, Proxen
