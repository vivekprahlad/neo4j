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
  index :name
  
end

p1 = PersonX.new :name => 'p1'
p2 = PersonX.new :name => 'p2'

puts p1.name
puts p2.name

p1.friends << p2

p1.friends.each {|x| puts x[:name]}

Neo4j::Transaction.finish

Neo4j::Transaction.run do

  # THIS DOES NOT YET WORK
  # Have to fix how the IndexSearcher uses path paremter, see Lucene::Index#find
  # searcher = IndexSearcher.new(@index_info.storage) and storage parameter is a RJB class that does not give the path
  #

  people = PersonX.find(:name => 'p1')
  p1 = people[0]
  puts "Found #{p1[:name]}"
end