module Proxen
  def self.blankify(klass)
    klass.class_eval do
      instance_methods.each do |sym|
        undef_method(sym) unless sym.to_s =~ /__/
      end
    end
  end

  def self.conditional(options)
    case
    when options[:if]
      "sym.to_s =~ #{options[:if].inspect}"
    when options[:unless]
      "! (sym.to_s =~ #{options[:unless].inspect})"
    else
      "true"
    end
  end

  def proxy_to(*targets)
    options = targets.last.is_a?(Hash) ? targets.pop : {}
    targets = Array(targets).flatten

    Proxen.blankify(self) if options[:blank_slate]

    class_eval(<<-END, __FILE__, __LINE__)
      def method_missing(sym, *args, &block)
        super unless #{Proxen.conditional(options)}

        receiver = #{targets.inspect}.detect do |t|
          __send__(t).respond_to?(sym)
        end

        if receiver
          __send__(receiver).send(sym, *args, &block)
        else
          super
        end
      end
    END
  end
end

Class.send :include, Proxen
