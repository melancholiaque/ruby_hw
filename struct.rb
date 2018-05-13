module MyStruct
  def self.new(name, *arg_names, &block)
    if name.is_a? Symbol
      arg_names.unshift name
      name = nil
    end

    klass = Class.new(&block)

    klass.class_eval do

      attr_accessor(*arg_names)

      define_method :initialize do |*args|
        raise ArgumentError if args.count != arg_names.count
        arg_names.zip args.each do |n, v|
          instance_variable_set("@#{n}", v)
        end
      end

      def ==(other)
        other.class == self.class && other.values == values
      end

      def [](var)
        if var.is_a?(Integer)
          values[var]
        else
          instance_variable_get("@#{var}")
        end
      end

      def []=(var, obj)
        if var.is_a?(Integer)
          instance_variable_set(members[var], obj)
        else
          instance_variable_set("@#{var}", obj)
        end
      end

      def dig
        to_h.dig
      end

      def each
        values.each do |v|
          yield(v)
        end
      end

      def each_pair
        members.zip(values).map do |var, val|
          yield(var, val)
        end
      end

      def eql?(other)
        self.class == other.class && members == other.members
      end

      def hash
        to_h.hash
      end

      define_method :inspect do
        iv = instance_variables.map do |v|
          "#{v.to_s[1..-1]}=#{instance_variable_get(v).inspect}"
        end
        "<MyStruct #{name} #{iv.join ' '}>"
      end

      def length
        instance_variables.length
      end

      def members
        instance_variables
      end

      def select
        values.select do |v|
          yield(v)
        end
      end

      def size
        members.count
      end

      def to_a
        values
      end

      def to_h
        Hash[members.zip(values)]
      end

      def values
        members.map { |v| instance_variable_get(v) }
      end

      def values_at(*selector)
        selector.map { |k| self[k] }
      end

      def is_a?(type)
        return true if type == MyStruct
        super
      end

      alias_method :to_s, :inspect
    end

    const_set(name, klass) if name

    klass
  end
end

if $PROGRAM_NAME == __FILE__
  s = MyStruct.new('Baz', :foo, :bar)
  a = s.new('a', 'b')
  b = MyStruct::Baz.new('c', 'd')
  puts a, b
  puts "a==b ---> #{a == b}"
  b[:foo] = 'a'
  b[1] = 'b'
  puts a, b
  puts "a==b ---> #{a == b}"
  puts "a[0] ---> #{a[0]}"
  puts "a[:foo] ---> #{a[:foo]}"
  puts "a['foo'] ---> #{a['foo']}"
  puts "a.each { |x| puts(x) } --->"
  a.each { |x| puts(x) }
  puts "a.each_pair { |name, value| puts(\"\#{name} => \#{value}\") } --->"
  a.each_pair { |name, value| puts("#{name} => #{value}") }
  puts "a.eql?(b) ---> #{a.eql?(b)}"
  puts "a.hash ---> #{a.hash}"
  puts "a.to_s ---> #{a.to_s}"
  puts "a.inspect ---> #{a.inspect}"
  puts "a.length ---> #{a.length}"
  puts "a.members ---> #{a.members}"
  puts "a.select { |v| v == 'a' } ---> #{a.select { |v| v == 'a' }}"
  puts "a.size ---> #{a.size}"
  puts "a.to_a ---> #{a.to_a}"
  puts "a.to_h ---> #{a.to_h}"
  puts "a.values ---> #{a.values}"
  puts "a.values_at(:foo, 1, :q) ---> #{a.values_at(:foo, 1, :q)}"
end
