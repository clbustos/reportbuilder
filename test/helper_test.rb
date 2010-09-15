begin
require 'RMagick'
$rmagick=true
rescue LoadError
$rmagick=false
end
$:.unshift(File.dirname(__FILE__)+"/../lib")
require "reportbuilder"
require 'nokogiri'
require 'minitest/unit'
require 'tmpdir'
require 'fileutils'
require 'tempfile'



MiniTest::Unit.autorun