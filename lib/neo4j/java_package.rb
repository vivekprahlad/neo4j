
require 'rubygems'
gem 'rjb'
require 'rjb'

# Loads the JVM with the given <tt>classpath</tt> and arguments to the jre.
# All needed .jars should be included in <tt>classpath</tt>.
def load_jvm(classpath, jargs)
  Rjb::load(classpath, jargs)
end

class JavaPackage

  def initialize(pack_name, parent_pack = nil)
    @pack_name = pack_name
    @parent_pack = parent_pack
    @cache = {}
    puts "Create pack #{pack_name}"
  end

  def method_missing(m, *args)
    # return if possible old module/class
    @cache[m] ||= create_package_or_class(m)
  end

  def create_package_or_class(m)
    method = m.to_s
    if upcase?(method)
      puts "Import #{self}.#{method}"
      Rjb::import("#{self}.#{method}")
    else
      JavaPackage.new(method, self)
    end
  end

  def to_s
    if @parent_pack
      "#{@parent_pack.to_s}.#@pack_name"
    else
      "#@pack_name"
    end
  end

  def upcase?(a)
    first_letter = a[0]
    first_letter >= 65 && first_letter <= 90
  end

  @@cache = {}
   def self.new(pack_name, parent_pack = nil)
      return @@cache[pack_name] if !parent_pack && @@cache[pack_name]
      puts "INIT #{pack_name}"
      super
  end
end

def org
  JavaPackage.new('org')
end

def java
  JavaPackage.new('java')
end

