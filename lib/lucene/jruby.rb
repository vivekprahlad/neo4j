module Lucene
  # Constants that are specific for JRuby

  STORE_YES = org.apache.lucene.document.Field::Store::YES
  STORE_NO  = org.apache.lucene.document.Field::Store::NO

  INDEX_ANALYZED     = org.apache.lucene.document.Field::Index::ANALYZED
  INDEX_NOT_ANALYZED = org.apache.lucene.document.Field::Index::NOT_ANALYZED
  OCCUR_MUST         = org.apache.lucene.search.BooleanClause::Occur::MUST
end
