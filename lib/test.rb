require 'neo4j'
Lucene::Config.setup.merge!({:store_on_file => true, :storage_path => '/tmp/foo'})


#@index = Lucene::Index.new('myindex')
#@index.field_infos[:name] = Lucene::FieldInfo.new(:store => true)
#@index << {:id => '1', :name => 'kalle'}
#@index.commit
#result = @index.find(:name=>"kalle")
#
#puts "Result #{result.size}"

#exit

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

p1.del

Neo4j::Transaction.finish

Neo4j::Transaction.run do

  people = PersonX.find(:name => 'p2')
  p1 = people[0]
  puts "Found #{p1[:name]}"
end