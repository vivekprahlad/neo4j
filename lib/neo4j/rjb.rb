require 'java_package'
require 'fileutils' # just for cleaning test data

require 'jars/neo4j-kernel-1.0.jar'
require 'jars/geronimo-jta_1.1_spec-1.1.1.jar'

load_jvm(['-Xms128m', '-Xmx1024m'])

FileUtils.rm_rf('/tmp/foo')

puts "\nCreate DB"
db = org.neo4j.kernel.EmbeddedGraphDatabase.new('/tmp/foo')

puts "Create db"
tx = db.beginTx
puts "created tx = #{tx}"

node = db.createNode
puts "Created node #{node} with id #{node.getId}"

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
