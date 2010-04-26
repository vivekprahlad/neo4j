include Java  if defined? JRUBY_VERSION

module Lucene
  # Constants that are specific for JRuby

  STORE_YES = org.apache.lucene.document.Field::Store::YES
  STORE_NO  = org.apache.lucene.document.Field::Store::NO

  INDEX_ANALYZED     = org.apache.lucene.document.Field::Index::ANALYZED
  INDEX_NOT_ANALYZED = org.apache.lucene.document.Field::Index::NOT_ANALYZED
  OCCUR_MUST         = org.apache.lucene.search.BooleanClause::Occur::MUST
  OCCUR_SHOULD       = org.apache.lucene.search.BooleanClause::Occur::SHOULD

  RESOLUTION_DAY     = org.apache.lucene.document.DateTools::Resolution::DAY
  RESOLUTION_SECOND  = org.apache.lucene.document.DateTools::Resolution::SECOND
end
