# -------------------------------------------------
# Stuff to make C Ruby and JRuby a bit more similar
# TODO maybe we should put this somewhere else - duplicated code

class Array
  def to_java(arg)
    self
  end
end


java.lang.String.new.class.class_eval do
  def wrapper
    case self._classname
      when 'org.neo4j.kernel.impl.core.NodeProxy'
        Neo4j::Node.new(self)
      when  'org.neo4j.kernel.impl.core.RelationshipProxy'
        Neo4j::Relationship.new(self)
      else
        raise "Unknown class #{self._classname}"
    end
  end
end

# Extend Neo4j

module Neo4j
  Neo4j.const_set(:OUTGOING, org.neo4j.graphdb.Direction.OUTGOING)
  Neo4j.const_set(:INCOMING, org.neo4j.graphdb.Direction.INCOMING)
  Neo4j.const_set(:BOTH, org.neo4j.graphdb.Direction.BOTH)
  Neo4j.const_set(:ALL_BUT_START_NODE, org.neo4j.graphdb.ReturnableEvaluator.ALL_BUT_START_NODE)
  Neo4j.const_set(:END_OF_GRAPH, org.neo4j.graphdb.StopEvaluator.END_OF_GRAPH)

  order = Rjb::import 'org.neo4j.graphdb.Traverser$Order'
  Neo4j.const_set(:BREADTH_FIRST, order.BREADTH_FIRST)


  class ReferenceNode
    def self.instance
      @instance ||= Neo4j::Transaction.run { ReferenceNode.new(Neo4j.instance.getReferenceNode().wrapper) }
    end
  end

  class Relationship
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaRelationshipMixin
    extend Forwardable

    def_delegators :@rjb_rel, :getId, :delete, :setProperty, :hasProperty, :getType

    def initialize(rjb_node)
      @rjb_rel = rjb_node
    end

    def getStartNode
      @rjb_rel.getStartNode.wrapper
    end

    def getEndNode
      @rjb_rel.getEndNode.wrapper
    end

    def getOtherNode(other)
      @rjb_rel.getOtherNode(other._java_node.rjb_node)      
    end


    def self.new(*args)
      # expect either a hash or a RJB java node
      if (args.size >= 3)
        rel = Neo4j.create_rel(args[0], args[1], args[2], args[3])
        super(rel)
      else
        super
      end
    end
  end

  class Node
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaListMixin
    include Neo4j::JavaNodeMixin
    extend Forwardable
    
    def_delegators :@rjb_node, :getId, :delete, :setProperty, :hasProperty, :traverse

    def initialize(rjb_node)
      @rjb_node = rjb_node
    end

    def rjb_node
      @rjb_node
    end

    def createRelationshipTo(to, java_type)
      @rjb_node.createRelationshipTo(to._java_node.rjb_node, java_type)
    end
    
    def self.new(*args)
      # expect either a hash or a RJB java node
      arg = args[0] || {}
      if (arg.respond_to?(:each_pair))
        node = Neo4j.create_node(args[0] || {})
        yield node if block_given?
        Neo4j.event_handler.node_created(node)
        super(node)
      else
        super
      end
    end

    def self.wrap(java_node)

    end

    def has_property?(p)
      hasProperty(p)
    end

    def getProperty(k)
      value = @rjb_node.getProperty(k)
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
      return @rjb_node.getRelationships if args.length == 0

#      raise "Called getRelationships on a none Neo4j Node" if self._classname != 'org.neo4j.kernel.impl.core.NodeProxy'
      # Match getRelationships(Direction dir)
#      raise "Unknown argument #{args.inspect}, not an RJB thingy" unless args[0].respond_to?(:_classname)
      return @rjb_node._invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', args[0]) if args[0]._classname == "org.neo4j.graphdb.Direction"

      # Match getRelationships(RelationshipType type, Direction dir)
      raise "Expects two arguments, got #{args.lentgh}" unless args.length == 2
#      raise "First arg should be org.neo4j.graphdb.DynamicRelationshipType, got '#{args[0]._classname}'" unless args[0]._classname == "org.neo4j.graphdb.DynamicRelationshipType"
#      raise "Second arg should be org.neo4j.graphdb.Direction, got '#{args[0]._classname}'" unless args[1]._classname == "org.neo4j.graphdb.Direction"
      @rjb_node._invoke('getRelationships', 'Lorg.neo4j.graphdb.RelationshipType;Lorg.neo4j.graphdb.Direction;', args[0], args[1])
    end
  end
end





