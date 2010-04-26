require 'rubygems'
gem 'rjb'
require 'rjb'

# Loads the JVM with the given <tt>classpath</tt> and arguments to the jre.
# All needed .jars should be included in <tt>classpath</tt>.

module Kernel
  alias rjb_original_require require

  def require(path)
    rjb_original_require(path)
  rescue LoadError
     # check that it's not a jar file
    raise unless path =~ /\.jar/

    # This will maybe use the wrong jar file from a previous version of the GEM
    #puts "LOAD PATH #{$LOAD_PATH}"
    found_path = $LOAD_PATH.reverse.find{|p| File.exist?(File.join(p,path))}
    raise unless found_path

    abs_path = File.join(found_path, path)
    # check that the file exists
    raise unless  File.exist?(abs_path)

    # try to load it using RJB
    @@rjb_jars ||= []
    @@rjb_jars << abs_path unless @@rjb_jars.include?(abs_path)
    # TODO
  end

  @@jvm_loaded = false

  def load_jvm(jargs)
    # avoid starting the JVM twice
    return if @@jvm_loaded
    
    @@jvm_loaded = true
    classpath = ENV['CLASSPATH'] ||= ''
    @@rjb_jars.each do |jar|
      classpath += File::PATH_SEPARATOR unless classpath.empty?
      classpath += jar
    end
    Rjb::load(classpath, jargs)
  end
end

class JavaPackage

  def initialize(pack_name, parent_pack = nil)
    @pack_name = pack_name
    @parent_pack = parent_pack
    @cache = {}
  end

  def method_missing(m, *args)
    # return if possible old module/class
    @cache[m] ||= create_package_or_class(m)
  end
  def create_package_or_class(m)
    method = m.to_s
    if class?(method)
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

  def class?(a)
    first_letter = a[0]
    first_letter >= 65 && first_letter <= 90
  end

  @@cache = {}
   def self.new(pack_name, parent_pack = nil)
      @@cache[pack_name] ||= super
  end
end

def org
  JavaPackage.new('org')
end

def java
  JavaPackage.new('java')
end

