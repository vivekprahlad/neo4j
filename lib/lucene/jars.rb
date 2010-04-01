puts "JRUBY DEFINED " if defined? JRUBY_VERSION
puts "JRUBY NOT DEFINED " unless defined? JRUBY_VERSION
include Java  if defined? JRUBY_VERSION

module Lucene
  require 'lucene/jars/lucene-core-2.9.1.jar'
end
