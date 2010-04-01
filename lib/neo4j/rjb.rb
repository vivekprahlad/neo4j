# THIS IS JUST A TEST FILE, not included  by top level neo4j.rb file

require 'java_package'
require 'fileutils' # just for cleaning test data

require 'jars/neo4j-kernel-1.0.jar'
require 'jars/geronimo-jta_1.1_spec-1.1.1.jar'

load_jvm(['-Xms128m', '-Xmx1024m'])

FileUtils.rm_rf('/tmp/foo')


module Neo4j

end
require 'mixins/java_property_mixin'
require 'mixins/java_node_mixin'

puts "\nCreate DB"
db = org.neo4j.kernel.EmbeddedGraphDatabase.new('/tmp/foo')

# Extend the node class
tx = db.beginTx
db.getReferenceNode.class.class_eval do
  include Neo4j::JavaPropertyMixin
  include Neo4j::JavaNodeMixin
  
  def has_property?(p) hasProperty(p) end

  def getProperty(k)
    puts "Get #{k}"
    value = super
    case value._classname
      when "java.lang.Integer" then value.intValue
      when "java.lang.String" then value.toString
      when "java.lang.Double" then value.doubleValue
      when "java.lang.Boolean" then value.booleanValue
      else raise "TODO unknown type '#{value._classname}'"
    end

  end

  def getRelationships(*args)
    # Match getRelationships()
    return super if args.length == 0

    # Match getRelationships(Direction dir)
    raise "Unknown argument #{args.inspect}, not an RJB thingy" unless args[0].respond_to?(:_classname)
    return _invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', args[0]) if args[0]._classname == "org.neo4j.graphdb.Direction"

    # Match getRelationships(RelationshipType type, Direction dir)
    raise "Expects two arguments, got #{args.lentgh}" unless args.length == 2
    raise "First arg should be org.neo4j.graphdb.DynamicRelationshipType, got '#{args[0]._classname}'" unless args[0]._classname == "org.neo4j.graphdb.DynamicRelationshipType"
    raise "Second arg should be org.neo4j.graphdb.Direction, got '#{args[0]._classname}'" unless args[1]._classname == "org.neo4j.graphdb.Direction"
    _invoke('getRelationships', 'Lorg.neo4j.graphdb.RelationshipType;Lorg.neo4j.graphdb.Direction;', args[0], args[1])
  end
end unless db.getReferenceNode.respond_to?(:has_property?)

tx.success
tx.finish

puts "DIRECTION CLASSNAME #{org.neo4j.graphdb.Direction.OUTGOING._classname}"

puts "Create db"
tx = db.beginTx
puts "created tx = #{tx}"

node = db.createNode
node[:name] = 'andreas' #node.setProperty("name", "andreas")

puts "ID =  #{node.getId}"
exit

node2 = db.createNode

java_type = org.neo4j.graphdb.DynamicRelationshipType.withName("friends")
puts "REL TYPE #{java_type._classname}"
node.createRelationshipTo(node2, java_type)

#node.getRelationships(org.neo4j.graphdb.Direction.OUTGOING)
#iterable = node._invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', org.neo4j.graphdb.Direction.OUTGOING)
iterable = node.getRelationships(java_type, org.neo4j.graphdb.Direction.OUTGOING) #', 'Lorg.neo4j.graphdb.Direction;', org.neo4j.graphdb.Direction.OUTGOING)

iterator = iterable.iterator
puts "Iterator #{iterator} clazz #{iterator._classname}"

puts "Has next #{iterator.hasNext}"
rel = iterator.next
puts "Rel #{rel} clazz #{rel._classname}"
tx.success
tx.finish

puts "Shutdown db = #{db.inspect} : #{db}"
db.shutdown

puts "END"
