# rjb_ext is needed to setup the classpath for the RJB CRuby JARs
require 'rjb_ext' unless defined? JRUBY_VERSION

require 'logger'
$LUCENE_LOGGER = Logger.new(STDOUT)
$LUCENE_LOGGER.level = Logger::WARN

require 'lucene/jars'
# the last thing we should do after loading all the source code is starting the JVM
load_jvm(['-Xms128m', '-Xmx1024m']) unless defined? JRUBY_VERSION

require 'lucene/config'
require 'lucene/document'
require 'lucene/field_info'
require 'lucene/hits'
require 'lucene/index'
require 'lucene/index_info'
require 'lucene/index_searcher'

require 'lucene/query_dsl'
require 'lucene/transaction'

if defined? JRUBY_VERSION
  require 'lucene/jruby'
else
  require 'lucene/rjb'
end
