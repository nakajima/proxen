module Proxen
  def proxy_to(target, options={})
    if options[:blank_slate]
      class_eval do
        instance_methods.each do |sym|
          undef_method(sym) unless sym.to_s =~ /__/
        end
      end
    end
    
    cond = options[:if] ? "sym.to_s =~ #{options[:if].inspect}" : "true"
    
    class_eval(<<-END, __FILE__, __LINE__)
      def method_missing(sym, *args, &block)
        if #{cond}
          #{target}.send(sym, *args, &block)
        else
          super
        end
      end
    END
  end
end

Class.send :include, Proxen