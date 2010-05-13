# -------------------------------------------------
# Stuff to make C Ruby and JRuby a bit more similar
# TODO maybe we should put this somewhere else - duplicated code

class Array
  def to_java(arg)
    self
  end
end

class Object
  def method_missing(m, * args, & block)
   puts "Method missing for #{self._classname}"
   puts "Method #{m}, args #{args.inspect}"

  end
end

def override_after(obj, u_meth, m, &p)
  puts "OVERRIDE #{m}"

  begin
    u_meth.bind(obj).call(m, args)
  rescue
    puts "Not available"
  end

end

java.lang.Object.new.class.class_eval do

  overrides = {:toString => Proc.new { puts "HOHO"; k = yield; puts "---K = #{k}"}}

#  methods.sort.each {|x| puts "METHOD #{x}"}
#  instance_variables.sort.each {|x| puts "VAR #{x}"}
  k = instance_method(:method_missing)

  puts "K = #{k}"
  define_method(:method_missing) do |m, *args|
    puts "KALLE2 #{m.class}, #{m}, #{args.inspect}"
    puts "MEMBER #{(overrides.member?(m))}"
    s = self
    begin
      overrides[m].call do
        puts "CALL METHOD #{m} on #{s}"
        #k.bind(s).call(m, args)
      end if (overrides.member?(m))
      #k.bind(self).call(m, args)
    rescue
      puts "Not available"      
    end
  end
  
  def method_missing2(m, *args, &block)
    puts "Method missing for #{self._classname}"
    puts "Method #{m}, args #{args.inspect}"
  end
end

puts java.lang.String.new('asd').toString #kalle2(1,2,3)
exit
java.lang.String.new.class.class_eval do
  #alias_method :orig_method_missing, :method_missing

  methods.sort.each {|x| puts "METHOD #{x}"}
  instance_variables.sort.each {|x| puts "VAR #{x}"}
  
  def method_missing2(m, *args, &block)
#    puts "Method missing for #{self._classname}"
#    puts "Method #{m}, args #{args.inspect}"
    #orig_method_missing(m, args, &block)
    super
  end

  def wrapper2
    @_wrapper = case self._classname
      when 'org.neo4j.kernel.impl.core.NodeProxy'
        Neo4j::Node.new(self)
      when  'org.neo4j.kernel.impl.core.RelationshipProxy'
        Neo4j::Relationship.new(self)
      else
        raise "Unknown class #{self._classname}"
    end

    puts "WRAPPER #@_wrapper"
    puts "CLASSNAME #{getProperty('_classname')}" if wrapper?
    @_wrapper = wrapper_class.new(@_wrapper) if wrapper?
    @_wrapper
  end

  def wrapper?
    hasProperty('_classname')
  end

  def wrapper_class  # :nodoc:
    classname = getProperty('_classname')
    classname.split("::").inject(Kernel) do |container, name|
      container.const_get(name.to_s)
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

  module RjbPropertyMixin
    def getPropertyKeys
      k = @rjb_obj.getPropertyKeys
      IteratorConverter.new(k.iterator) do |x|
        x.toString
      end
    end

    def has_property?(p)
      hasProperty(p)
    end

    def getProperty(k)
      value = @rjb_obj.getProperty(k)
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
  end


  class Relationship
    include Neo4j::JavaPropertyMixin
    include Neo4j::JavaRelationshipMixin
    include RjbPropertyMixin
    extend Forwardable

    def_delegators :@rjb_obj, :getId, :delete, :setProperty, :hasProperty, :getType

    def initialize(rjb_node)
      @rjb_obj = rjb_node
    end

    def getStartNode
      @rjb_obj.getStartNode.wrapper
    end

    def getEndNode
      @rjb_obj.getEndNode.wrapper
    end

    def getOtherNode(other)
      @rjb_obj.getOtherNode(other._java_node.rjb_node)      
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
    include RjbPropertyMixin
    extend Forwardable
    
    def_delegators :@rjb_obj, :getId, :delete, :setProperty, :hasProperty, :traverse, :removeProperty, :hasRelationship

    def initialize(rjb_node)
      @rjb_obj = rjb_node
    end

    def rjb_node
      @rjb_obj
    end

    def hash
      @rjb_obj.hashCode
    end
    

    def createRelationshipTo(to, java_type)
      r = @rjb_obj.createRelationshipTo(to._java_node.rjb_node, java_type)
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


    def getSingleRelationship(type,dir)
      r = @rjb_obj.getSingleRelationship(type,dir)
      Neo4j::Relationship.new(r)
    end
    
    def getRelationships(*args)
      # Match getRelationships()
      rels = if args.length == 0
        @rjb_obj.getRelationships
      elsif args[0]._classname == "org.neo4j.graphdb.Direction"
        @rjb_obj._invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', args[0])
      else
        @rjb_obj._invoke('getRelationships', 'Lorg.neo4j.graphdb.RelationshipType;Lorg.neo4j.graphdb.Direction;', args[0], args[1])
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





