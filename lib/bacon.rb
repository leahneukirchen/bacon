# Bacon -- small RSpec clone.

module Bacon
  Counter = Hash.new(0)
  ErrorLog = ""

  def self.result_string
    "%d specifications (%d requirements), %d failures, %d errors" % 
      [Counter[:specifications], Counter[:requirements],
       Counter[:failed],         Counter[:error]]
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
      
      puts name
      instance_eval(&block)
      puts
    end
    
    def before(&block); @before << block; end
    def after(&block);  @after << block; end
    
    def it(description, &block)
      Bacon::Counter[:requirements] += 1
      run_specify description, block
    end
    
    def run_specify(description, spec)
      print "- #{description}"
      
      @before.each { |block| instance_eval(&block) }
      instance_eval(&spec)
      @after.each { |block| instance_eval(&block) }
    rescue Object => e
      if e.kind_of? Bacon::Error
        puts " [#{e.count_as.to_s.upcase}]"
        Bacon::Counter[e.count_as] += 1
      else
        puts " [ERROR: #{e.class}]"
        Bacon::Counter[:errors] += 1
      end
      
      ErrorLog << "#{e.class}: #{e.message}\n"
      e.backtrace.find_all { |line| line !~ /\/bacon.rb:\d+/ }.
        each_with_index { |line, i|
        ErrorLog << "\t#{line}#{i==0?": "+@name + " - "+description:""}\n"
      }
      ErrorLog << "\n"
    else
      puts
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
  rescue *(exceptions.empty? ? RuntimeError : exceptions)
    true
  rescue
    false
  else
    false
  end
end

class Object
  def should(*args, &block)
    Should.new(self).be(*args, &block)
  end

  def describe(name, &block)
    Bacon::Counter[:specifications] += 1
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

  def not
    @negated = !@negated
    self
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
    unless @negated ^ yield(@object, *args)
      raise Bacon::Error.new(:failed, "")
    end
    Bacon::Counter[:passed] += 1
    @object
  end

  def method_missing(name, *args, &block)
    satisfy { |x|
      name = "#{name}?"  if name.to_s =~ /\w/
      x.__send__(name, *args, &block)
    }
  end
end
