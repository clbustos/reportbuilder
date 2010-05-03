begin
require 'RMagick'
$rmagick=true
rescue LoadError
$rmagick=false
end
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'minitest/unit'
require 'tmpdir'
require "reportbuilder"
MiniTest::Unit.autorun