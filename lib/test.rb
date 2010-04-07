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

p1.friends << p2

p1.friends.each {|x| puts x[:name]}

Neo4j::Transaction.finish
