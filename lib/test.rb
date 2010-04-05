require 'neo4j'
Neo4j.start
Neo4j::Transaction.new
a = Neo4j::Node.new
b = Neo4j::Node.new :name => 'b'
a[:name] = 'a'


a.rels.outgoing(:friends) << b
a.rels.each {|x| puts "Rel #{x.getEndNode[:name]}"}

class PersonX
  include Neo4j::NodeMixin
  has_n :friends
  property :name
  # lucene index does not yet work does not work because lucene does not work with RJB
  # Need to access in RJB -  org.apache.lucene.document.Field::Store::YES : org.apache.lucene.document.Field::Store::NO 
end

p1 = PersonX.new :name => 'p1'
p2 = PersonX.new :name => 'p2'

puts p1.name
puts p2.name

# the following line does not work since RJB need to load an enum in an Inner class -  org.neo4j.graphdb.Traverser::Order::BREADTH_FIRST
# Should be possible to solve, check RJB mailing list for Enum
p1.friends << p2

# This does not yet work ...
p1.friends.each {|x| puts x[:name]}

Neo4j::Transaction.finish
