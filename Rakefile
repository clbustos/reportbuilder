#!/usr/bin/ruby
# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")

require 'rubygems'
require 'hoe'
require 'reportbuilder'
Hoe.plugin :git
Hoe.spec 'reportbuilder' do
  self.testlib=:minitest
  self.version=ReportBuilder::VERSION
  self.rubyforge_name = 'ruby-statsample'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.url = "http://ruby-statsample.rubyforge.org/reportbuilder/"
  self.extra_deps << ["clbustos-rtf","~>0.4.0"] << ['text-table', "~>1.2"] << ["prawn", "~>0.8.4"] <<  ["prawn-svg","~>0.9.1"]
  self.extra_dev_deps << ["nokogiri", "~>1.5"] 
end

# vim: syntax=ruby
