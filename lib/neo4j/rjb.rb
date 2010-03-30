require 'java_package'
require 'fileutils' # just for cleaning test data

libpath = File.expand_path(File.join(File.dirname(__FILE__), 'jars'))
puts "LIBPATH #{libpath}"

classpath = ENV['CLASSPATH'] ||= ''
classpath += File::PATH_SEPARATOR + File.join(libpath, 'neo4j-kernel-1.0.jar')
classpath += File::PATH_SEPARATOR + File.join(libpath, 'geronimo-jta_1.1_spec-1.1.1.jar')

puts "LOAD JVM"
load_jvm(classpath, ['-Xms128m', '-Xmx1024m'])

puts "create graph db"

FileUtils.rm_rf('/tmp/foo')
db = org.neo4j.kernel.EmbeddedGraphDatabase.new('/tmp/foo') 

puts "Create db"
tx = db.beginTx
puts "created tx = #{tx}"

node = db.createNode
puts "Created node #{node}"
puts "Node id #{node.getId} "

node.setProperty("name", "andreas")
node.setProperty("age", 40)

name = node.getProperty("name")

puts "Name #{name._classname} #{name.toString}"
age = node.getProperty("age")
puts "Age #{age._classname}, #{age.intValue}"

tx.success
tx.finish

puts "Shutdown db = #{db.inspect} : #{db}"
db.shutdown

puts "END"