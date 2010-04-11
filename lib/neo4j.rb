# external dependencies
require 'singleton'
require 'thread'
require 'delegate'
require 'forwardable'

# rjb_ext is needed to setup the classpath for the RJB CRuby JARs
require 'rjb_ext' unless defined? JRUBY_VERSION

# external jars
require 'neo4j/jars'

# lucene
require 'lucene'

# config
require 'neo4j/config'

# mixins
require 'neo4j/mixins/property_class_methods'
require 'neo4j/mixins/rel_class_methods'
require 'neo4j/mixins/java_relationship_mixin'
require 'neo4j/mixins/java_property_mixin'
require 'neo4j/mixins/java_node_mixin'
require 'neo4j/mixins/java_list_mixin'
require 'neo4j/mixins/relationship_mixin'
require 'neo4j/mixins/node_mixin'
require 'neo4j/mixins/migration_mixin'

# relationships
require 'neo4j/relationships/decl_relationship_dsl'
require 'neo4j/relationships/wrappers'
require 'neo4j/relationships/traversal_position'
require 'neo4j/relationships/has_n'
require 'neo4j/relationships/relationship_dsl'
require 'neo4j/relationships/node_traverser'
require 'neo4j/relationships/has_list'

# neo4j
require 'neo4j/indexer'
require 'neo4j/reference_node'
require 'neo4j/batch_inserter'
require 'neo4j/neo'
require 'neo4j/event_handler'
require 'neo4j/transaction'
require 'neo4j/search_result'
require 'neo4j/node'
require 'neo4j/relationship'
require 'neo4j/version'


if defined? JRUBY_VERSION
  module Neo4j
    OUTGOING = org.neo4j.graphdb.Direction::OUTGOING
    INCOMING = org.neo4j.graphdb.Direction::INCOMING
    BOTH = org.neo4j.graphdb.Direction::BOTH

    BREADTH_FIRST = org.neo4j.graphdb.Traverser::Order::BREADTH_FIRST
    ALL_BUT_START_NODE = org.neo4j.graphdb.ReturnableEvaluator::ALL_BUT_START_NODE
    END_OF_GRAPH = org.neo4j.graphdb.StopEvaluator::END_OF_GRAPH
  end
else
  require 'neo4j_rjb_ext'
end


