# Proxen

Easy `method_missing` proxies.

## Usage

It's sort of like ActiveSupport's `Module#delegate`, only for proxying.

    class Something
      proxy_to :other_thing

      def other_thing
        OtherThing.new # or whatever
      end
    end

## Conditional Proxying via `:if` (or `:unless`)

You can pass a regex, so only matching methods will be proxied:

    class Something
      proxy_to :other_thing, :if => /^[^_]/

      def other_thing
        OtherThing.new
      end
    end

    Something.new.hello # Will be proxied
    Something.new._hello # Won't be proxied

How 'bout a symbol instead:

    class Something
      proxy_to :other_thing, :if => :should?

      def should?(sym)
        PROXY_METHODS.include?(sym)
      end

      def other_thing
        OtherThing.new
      end
    end

You can also use a Proc:

    class Something
      proxy_to :other_thing, :if => proc { |sym| sym == :yes }

      def other_thing
        OtherThing.new
      end
    end

You can also make the class a blank slate, meaning *everything* will be proxied:

    class Something
      proxy_to :other_thing, :blank_slate => true

      def other_thing
        OtherThing.new
      end
    end

    Something.new.inspect # Proxied to other_thing

That's all for now.

<pre>
(c) Copyright 2009 Pat Nakajima

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
</pre>
