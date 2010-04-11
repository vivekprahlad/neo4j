# the last thing we should do after loading all the source code is starting the JVM
load_jvm(['-Xms128m', '-Xmx1024m'])

# -------------------------------------------------
# Stuff to make C Ruby and JRuby a bit more similar
# TODO maybe we should put this somewhere else

class Array
  def to_java(arg)
    self
  end
end

# -------------------------------------------------
# Extend Neo4j
module Neo4j
  Neo4j.const_set(:OUTGOING, org.neo4j.graphdb.Direction.OUTGOING)
  Neo4j.const_set(:INCOMING, org.neo4j.graphdb.Direction.INCOMING)
  Neo4j.const_set(:BOTH, org.neo4j.graphdb.Direction.BOTH)
  Neo4j.const_set(:ALL_BUT_START_NODE, org.neo4j.graphdb.ReturnableEvaluator.ALL_BUT_START_NODE)
  Neo4j.const_set(:END_OF_GRAPH, org.neo4j.graphdb.StopEvaluator.END_OF_GRAPH)

  order = Rjb::import 'org.neo4j.graphdb.Traverser$Order'
  Neo4j.const_set(:BREADTH_FIRST, order.BREADTH_FIRST)


# TODO - THIS IS NOT THE CORRECT WAY TO DO IT !!!
  java.lang.String.new.class.class_eval do
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaNodeMixin

    def has_property?(p)
      hasProperty(p)
    end

    # TODO Really really ugly, since we extend all java classes we have to avoid
    def ==(other)
      #puts "Compare #{_classname} == #{other._classname}"
      return super if _classname == 'org.neo4j.kernel.impl.core.NodeProxy'
      return object_id == other.object_id
    end

    def getProperty(k)
      value = super
      case value._classname
        when "java.lang.Integer" then
          value.intValue
        when "java.lang.String" then
          value.toString
        when "java.lang.Double" then
          value.doubleValue
        when "java.lang.Boolean" then
          value.booleanValue
        else
          raise "TODO unknown type '#{value._classname}'"
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
  end

end





