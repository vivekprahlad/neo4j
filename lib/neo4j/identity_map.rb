module Neo4j
  class IdentityMap
    attr_accessor :identity_map

    def initialize
      @identity_map = java.util.HashMap.new
    end

    def load(neo_entity)
      if neo_entity.respond_to?(:_java_node)
        @identity_map.get(neo_entity.neo_id)
      else
        # TODO, identity map for relationships
        nil
      end
    end

    def store(neo_entity, wrapped_entity)
      if neo_entity.respond_to?(:_java_node)
        @identity_map.put(neo_entity.neo_id, wrapped_entity)
      else
        # TODO, identity map for relationships
        nil
      end
    end


    def remove(neo_entity)
      @identity_map.remove(neo_entity.neo_id)
    end

    def clear
      @identity_map.clear
    end

    # ------------------------------------------------------------------------------------------------------------------
    # Class methods

    class << self
      def on_after_commit(*)
        instance.clear
      end

      def instance
        Thread.current[:neo4j_identity_mapl] ||= IdentityMap.new
      end

      def on_neo4j_started(db)
        puts "NEO STARTED"
        if not Neo4j::Config[:enable_identity_map]
          puts "NO IDENTITY MAP"
          db.event_handler.remove(self)
        end
      end
    end

  end

  Neo4j.unstarted_db.event_handler.add(IdentityMap)

end