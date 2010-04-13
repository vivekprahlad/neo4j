module Lucene
  store = Rjb::import 'org.apache.lucene.document.Field$Store'
  Lucene.const_set(:STORE_YES, store.YES)
  Lucene.const_set(:STORE_NO, store.NO)

  # org.apache.lucene.document.Field::Index::ANALYZED : org.apache.lucene.document.Field::Index::NOT_ANALYZED
  index = Rjb::import 'org.apache.lucene.document.Field$Index'
  Lucene.const_set(:INDEX_ANALYZED, index.ANALYZED)
  Lucene.const_set(:INDEX_NOT_ANALYZED, index.NOT_ANALYZED)

  # org.apache.lucene.search.BooleanClause::Occur::MUST
  boolean_clause = Rjb::import 'org.apache.lucene.search.BooleanClause$Occur'
  Lucene.const_set(:OCCUR_MUST, boolean_clause.MUST)

  # CRuby with in memory lucene db does not yet work, set default to store on file indexes
  Config.setup.merge!({:store_on_file => true, :storage_path => 'tmp/lucene'})
end
