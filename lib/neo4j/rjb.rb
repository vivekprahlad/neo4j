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
          include Neo4j::JavaNodeMixin
          include Neo4j::JavaListMixin
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
      puts "Define #{meth}"
      meta.send :define_method, meth.to_sym do
        puts "Proxy #{meth} for #{self}"
        node = super
        node.instance_eval do
          include Neo4j::JavaPropertyMixin
          include Neo4j::JavaNodeMixin
          include Neo4j::JavaListMixin
          include Neo4j::RjbPropertyMixin
          include Neo4j::RjbNodeMixin
        end
        node
      end
    end
  end

  def self.start_db # :nodoc:
    db = org.neo4j.kernel.EmbeddedGraphDatabase.new(Neo4j::Config[:storage_path])
    rjb_extend_node(db, %w[   createNode getNodeById getReferenceNode   ])
    rjb_extend_rel(db, %w[  getRelationshipById  ])
    #@neo.getRelationshipById(rel_id.to_i)
    db
  end

  module RjbPropertyMixin
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


  module RjbNodeMixin

    def getRelationships(* args)
      iter = if args.length == 0
        super
      elsif args[0]._classname == "org.neo4j.graphdb.Direction"
        self._invoke('getRelationships', 'Lorg.neo4j.graphdb.Direction;', args[0])
      else
        self._invoke('getRelationships', 'Lorg.neo4j.graphdb.RelationshipType;Lorg.neo4j.graphdb.Direction;', args[0], args[1])
      end

      puts "Extend iter ?"
      IteratorWrapper.new(iter)
    end
  end

  class IteratorWrapper # :nodoc:
    def initialize(iterator)
      @iterator = iterator
      Neo4j::rjb_extend_rel(@iterator, %w[next])
    end

    def iterator
      self
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





