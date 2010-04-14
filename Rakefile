#!/usr/bin/ruby
# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")

require 'rubygems'
require 'hoe'
require 'reportbuilder'

Hoe.spec 'reportbuilder' do
  self.testlib=:minitest
  self.version=ReportBuilder::VERSION
  self.rubyforge_name = 'ruby-statsample'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.url = "http://ruby-statsample.rubyforge.org/reportbuilder/"
  self.extra_deps << ["clbustos-rtf","~>0.2.1"] << ['text-table', "~>1.2"]
  self.extra_dev_deps << ["nokogiri", "~>1.4"] 
end

task :release  do 
  version="v#{ReportBuilder::VERSION}"
  sh %(git commit -a -m "Release #{version}")
  sh %(git tag "#{version}")
  sh %(git push origin --tags)
end

# vim: syntax=ruby
