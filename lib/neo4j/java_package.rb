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

    # get the path from where it was required
    local_path = File.expand_path(File.dirname(caller[0].sub(/:\d+:in.`.*?'/, '')))
    load_paths = [local_path] + $LOAD_PATH[0...-1]
    found_path = load_paths.find{|p| File.exist?(File.join(p,path))}
    puts "FOUND PATH #{found_path}"
    raise unless found_path
    
    abs_path = File.join(found_path, path)
    # check that the file exists
    raise unless  File.exist?(abs_path)

    # try to load it using RJB
    puts "ADD abs '#{abs_path}'"
    @rjb_jars ||= []
    @rjb_jars << abs_path unless @rjb_jars.include?(abs_path)
    # TODO
  end

  def load_jvm(jargs)
    classpath = ENV['CLASSPATH'] ||= ''
    @rjb_jars.each do |jar|
      classpath += File::PATH_SEPARATOR unless classpath.empty?
      classpath += jar
    end
#    classpath += File::PATH_SEPARATOR + File.join(libpath, 'neo4j-kernel-1.0.jar')
#    classpath += File::PATH_SEPARATOR + File.join(libpath, 'geronimo-jta_1.1_spec-1.1.1.jar')
    puts "LOAD JVM WITH '#{classpath}'"
    Rjb::load(classpath, jargs)
  end
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
    puts "m=#{m} #{@cache[m]}"
    @cache[m] ||= create_package_or_class(m)
  end

  def create_package_or_class(m)
    method = m.to_s
    puts "create package #{m}"
    if upcase?(method)
#      puts "Import #{self}.#{method}"
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
      @@cache[pack_name] ||= super
  end
end

def org
  JavaPackage.new('org')
end

def java
  JavaPackage.new('java')
end

