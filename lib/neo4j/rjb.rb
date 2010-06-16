# -------------------------------------------------
# Stuff to make C Ruby and JRuby a bit more similar
# TODO maybe we should put this somewhere else - duplicated code

class Array
  def to_java(arg)
    self
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


  def self.rjb_extend_rel(rel, methods)
    meta = class << rel;
      self;
    end
    methods.each do |meth|
      meta.send :define_method, meth.to_sym do
        rel = super
        rel.instance_eval do
          include Neo4j::JavaPropertyMixin
          include Neo4j::RjbPropertyMixin
          Neo4j::rjb_extend_node(self, %w[  getStartNode getEndNode getOtherNode  ])
        end
        rel
      end
    end
  end

  def self.rjb_extend_node(node, methods)
    meta = class << node;
      self;
    end
    methods.each do |meth|
      meta.send :define_method, meth.to_sym do
        node = super
        node.instance_eval do
          include Neo4j::JavaPropertyMixin
          include Neo4j::JavaNodeMixin
          include Neo4j::JavaListMixin
          include Neo4j::RjbPropertyMixin
          include Neo4j::RjbNodeMixin
          Neo4j::rjb_extend_rel(self, %w[  createRelationshipTo  ])
          Neo4j::rjb_extend_iterator(self, %w[traverse])
        end
        node
      end
    end
  end

  def self.rjb_extend_iterator(obj, methods)
    meta = class << obj;
      self;
    end

    methods.each do |meth|
      meta.send :define_method, meth.to_sym do
        IteratorWrapper.for_nodes(super)
      end
    end
  end
  
  def self.start_db # :nodoc:
    db = org.neo4j.kernel.EmbeddedGraphDatabase.new(Neo4j::Config[:storage_path])
    rjb_extend_node(db, %w[createNode getNodeById getReferenceNode])
    rjb_extend_rel(db, %w[getRelationshipById])
    rjb_extend_iterator(db, %w[getAllNodes])
    db
  end

  module RjbPropertyMixin

    def kind_of?(other)
      other.respond_to?(:_classname) && other._classname == 'java.lang.Class' && other.isInstance(self)
    end

    def hash
      self.hashCode
    end
    
    def getPropertyKeys
      k = super
      IteratorConverter.new(k.iterator) do |x|
        x.toString
      end
    end

    def getId
      super
    end

    def has_property?(p)
      hasProperty(p)
    end

    def getProperty(k)
      value = super
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

  module NodeMixin
    def set_and_marshal_property(key, value)
      bytes = []
      Marshal.dump(value).each_byte {|bb| bytes << bb}
      org.NeoBridge.setProperty(@_java_node, key.to_s, bytes)
    end

    def get_and_marshal_property(key)
      bytes = org.NeoBridge.getProperty(@_java_node, key.to_s)
      Marshal.load(bytes)
    end
  end

  module RjbNodeMixin

    def getRelationships(*args)
      iter = if args.length == 0
        super
      elsif args[0]._classname == "org.neo4j.graphdb.Direction"
        self._invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', args[0])
      else
        self._invoke('getRelationships', 'Lorg.neo4j.graphdb.RelationshipType;Lorg.neo4j.graphdb.Direction;', args[0], args[1])
      end
      IteratorWrapper.for_rels(iter)
    end

  end

  class IteratorWrapper # :nodoc:
    attr_reader :iterator

    private
    def initialize(iterator)
      @iterator = iterator
    end

    public
    def self.for_nodes(iterable)
      iter = iterable.iterator
      Neo4j::rjb_extend_node(iter, %w[next])
      new(iter)
    end

    def self.for_rels(iterable)
      iter = iterable.iterator
      Neo4j::rjb_extend_rel(iter, %w[next])
      new(iter)
    end

    def next
      @iterator.next
    end

    def hasNext
      @iterator.hasNext
    end

  end

  class IteratorConverter # :nodoc:
    def initialize(iterator, & proc)
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





