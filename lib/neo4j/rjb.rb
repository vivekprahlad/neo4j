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
    
    def_delegators :@rjb_node, :getId, :delete, :setProperty, :hasProperty, :traverse, :removeProperty, :hasRelationship, :getPropertyKeys

    def initialize(rjb_node)
      @rjb_node = rjb_node
    end

    def rjb_node
      @rjb_node
    end

    def hash
      @rjb_node.hashCode
    end
    
    def getPropertyKeys
      k = @rjb_node.getPropertyKeys
      IteratorConverter.new(k.iterator) do |x|
        x.toString        
      end
    end

    def createRelationshipTo(to, java_type)
      r = @rjb_node.createRelationshipTo(to._java_node.rjb_node, java_type)
      Relationship.new(r)
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
               # TODO remove ???
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
      rels = if args.length == 0
        @rjb_node.getRelationships
      elsif args[0]._classname == "org.neo4j.graphdb.Direction"
        @rjb_node._invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', args[0])
      else
        @rjb_node._invoke('getRelationships', 'Lorg.neo4j.graphdb.RelationshipType;Lorg.neo4j.graphdb.Direction;', args[0], args[1])
      end

      IteratorWrapper.new(rels, Neo4j::Relationship)
    end
  end

  class IteratorWrapper # :nodoc:
    def initialize(iterator, clazz)
      @iterator = iterator
      @clazz = clazz
    end

    def iterator
      self
    end
    
    def next
      n = @iterator.next
      return @clazz.new(n) if n
    end

    def hasNext
      @iterator.hasNext
    end
  end

  class IteratorConverter # :nodoc:
    def initialize(iterator, &proc)
      @iterator = iterator
      @proc = proc
    end

    def iterator
      self
    end

    def next
      n = @iterator.next
      return @proc.call(n) if n
    end

    def hasNext
      @iterator.hasNext
    end
  end

end





