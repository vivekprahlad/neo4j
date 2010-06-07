
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


  def self.start_db # :nodoc:
    org.neo4j.kernel.EmbeddedGraphDatabase.new(Neo4j::Config[:storage_path])
  end


  org.neo4j.kernel.impl.core.NodeProxy.class_eval do
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaNodeMixin
    include Neo4j::JavaListMixin
  end
  
end
