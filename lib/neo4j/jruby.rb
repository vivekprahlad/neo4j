
module Neo4j
  # Constants that are specific for JRuby

  # Defines outgoing relationships.
  OUTGOING = org.neo4j.graphdb.Direction::OUTGOING

  # Defines incoming relationships.
  INCOMING = org.neo4j.graphdb.Direction::INCOMING

  #  Defines both incoming and outgoing relationships.
  BOTH = org.neo4j.graphdb.Direction::BOTH

  # Constants for setting the breadth first traversal meaning the traverser will traverse all relationships on the current depth before going deeper.
  BREADTH_FIRST = org.neo4j.graphdb.Traverser::Order::BREADTH_FIRST

  # Constants for returnable evaluator that returns all nodes except start node.
  ALL_BUT_START_NODE = org.neo4j.graphdb.ReturnableEvaluator::ALL_BUT_START_NODE

  # Constants for traverse until the end of the graph.
  END_OF_GRAPH = org.neo4j.graphdb.StopEvaluator::END_OF_GRAPH


  org.neo4j.kernel.impl.core.NodeProxy.class_eval do
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaNodeMixin
    include Neo4j::JavaListMixin
  end



  org.neo4j.kernel.impl.core.RelationshipProxy.class_eval do
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaRelationshipMixin

    def end_node # :nodoc:
      id = getEndNode.getId
      Neo4j.load_node(id)
    end

    def start_node # :nodoc:
      id = getStartNode.getId
      Neo4j.load_node(id)
    end

    def other_node(node) # :nodoc:
      neo_node = node
      neo_node = node._java_node if node.respond_to?(:_java_node)
      id = getOtherNode(neo_node).getId
      Neo4j.load_node(id)
    end
  end

  class Relationship
    class << self
      # Returns a org.neo4j.graphdb.Relationship java object (!)
      # Will trigger a event that the relationship was created.
      #
      # === Parameters
      # type :: the type of relationship
      # from_node :: the start node of this relationship
      # end_node  :: the end node of this relationship
      # props :: optional properties for the created relationship
      #
      # === Returns
      # org.neo4j.graphdb.Relationship java object
      #
      # === Examples
      #
      #  Neo4j::Relationship.new :friend, node1, node2, :since => '2001-01-02', :status => 'okey'
      #
      def new(type, from_node, to_node, props={})
        Neo4j.create_rel(type, from_node, to_node, props)
      end
    end

  end


  class Node
    class << self
      # Returns a org.neo4j.graphdb.Node java object (!)
      # Will trigger a event that the node was created.
      #
      # === Parameters
      # *args :: can be a hash of properties to initialize the node with or empty
      #
      # === Returns
      # org.neo4j.graphdb.Node java object
      #
      # === Examples
      #
      #  Neo4j::Node.new
      #  Neo4j::Node.new :name => 'foo', :age => 100
      #
      def new(*args)
        node = Neo4j.create_node(args[0] || {})
        yield node if block_given?
        Neo4j.event_handler.node_created(node)
        node
      end
    end
  end

  class ReferenceNode
    def self.instance
      @instance ||= Neo4j::Transaction.run { ReferenceNode.new(Neo4j.instance.getReferenceNode()) }
    end
  end
  
end
