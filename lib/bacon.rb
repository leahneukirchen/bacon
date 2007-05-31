# Bacon -- small RSpec clone.

module Bacon
  Counter = Hash.new(0)
  ErrorLog = ""

  def self.result_string
    "%d specifications (%d requirements), %d failures, %d errors" % 
      [Counter[:specifications], Counter[:requirements],
       Counter[:failed],         Counter[:errors]]
  end

  def self.handle_specification(name)
    puts name
    yield
    puts
  end

  def self.handle_requirement(description)
    print "- #{description}"
    error = yield
    if error.empty?
      puts
    else
      puts " [#{error}]"
    end
  end

  class Error < RuntimeError
    attr_accessor :count_as
    
    def initialize(count_as, message)
      @count_as = count_as
      super message
    end
  end
  
  class Context
    def initialize(name, &block)
      @before = []
      @after = []
      @name = name
      
      Bacon.handle_specification(name) do
        instance_eval(&block)
      end
    end
    
    def before(&block); @before << block; end
    def after(&block);  @after << block; end
    
    def it(description, &block)
      Bacon::Counter[:specifications] += 1
      run_requirement description, block
    end
    
    def run_requirement(description, spec)
      Bacon.handle_requirement description do
        begin
          @before.each { |block| instance_eval(&block) }
          instance_eval(&spec)
          @after.each { |block| instance_eval(&block) }
        rescue Object => e
          ErrorLog << "#{e.class}: #{e.message}\n"
          e.backtrace.find_all { |line| line !~ /\/bacon.rb:\d+/ }.
            each_with_index { |line, i|
            ErrorLog << "\t#{line}#{i==0?": "+@name + " - "+description:""}\n"
          }
          ErrorLog << "\n"
          
          if e.kind_of? Bacon::Error
            Bacon::Counter[e.count_as] += 1
            e.count_as.to_s.upcase
          else
            Bacon::Counter[:errors] += 1
            "ERROR: #{e.class}"
          end
        else
          ""
        end
      end      
    end

    def raise?(*args, &block)
      block.raise?(*args)
    end
  end
end


class Object
  def true?; false; end
  def false?; false; end
end

class TrueClass
  def true?; true; end
end

class FalseClass
  def false?; true; end
end

class Proc
  def raise?(*exceptions)
    call
  rescue *(exceptions.empty? ? RuntimeError : exceptions) => e
    e
  # do not rescue other exceptions.
  else
    false
  end
end

class Float
  def close?(to, delta)
    (to.to_f - self).abs <= delta.to_f
  rescue
    false
  end
end

class Object
  def should(*args, &block)
    Should.new(self).be(*args, &block)
  end

  def describe(name, &block)
    Bacon::Context.new(name, &block)
  end
end


class Should
  # Kills ==, ===, =~, eql?, equal?, frozen?, instance_of?, is_a?,
  # kind_of?, nil?, respond_to?, tainted?
  instance_methods.each { |method|
    undef_method method  if method =~ /\?|^\W+$/
  }
  
  def initialize(object)
    @object = object
    @negated = false
  end

  def not(*args, &block)
    @negated = !@negated
    
    if args.empty?
      self
    else
      be(*args, &block)
    end
  end

  def be(*args, &block)
    case args.size
    when 0
      self
    else
      block = args.shift  unless block_given?
      satisfy(*args, &block)
    end
  end
    
  alias a  be
  alias an be
  
  def satisfy(*args, &block)
    if args.size == 1 && String === args.first
      description = args.shift
    else
      description = ""
    end

    r = yield(@object, *args)
    unless @negated ^ r
      raise Bacon::Error.new(:failed, description)
    end
    Bacon::Counter[:requirements] += 1
    @negated ^ r ? r : false
  end

  def method_missing(name, *args, &block)
    name = "#{name}?"  if name.to_s =~ /\w/
    
    desc = @negated ? "not " : ""
    desc << @object.inspect << "." << name.to_s
    desc << "(" << args.map{|x|x.inspect}.join(", ") << ")"
      
    satisfy(desc) { |x|
      x.__send__(name, *args, &block)
    }
  end

  def equal(value); self == value; end
  def match(value); self =~ value; end
end
