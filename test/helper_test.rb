$:.unshift(File.dirname(__FILE__)+"/../lib")
begin
  require 'simplecov'
  
  SimpleCov.start do
  add_filter '/test/'
  add_filter '/examples/'
  add_group 'Libraries', 'lib'
  end
rescue LoadError
end

require "reportbuilder"
require 'nokogiri'
require 'minitest/unit'
require 'tmpdir'
require 'fileutils'
require 'tempfile'



MiniTest::Unit.autorun
