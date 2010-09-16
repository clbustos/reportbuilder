$:.unshift(File.dirname(__FILE__)+"/../lib")
require "reportbuilder"
$base_dirname=File.dirname(__FILE__)
rb=ReportBuilder.new(:directory=>$base_dirname) do |rb|
  rb.graph(:name=>"Graph", :html_engine=>:ploticus) do |g|
   g.series_defaults :color=>'red', :bars=>{:width=>5}
   g.legend :show=>true, :position=>'nw', :background_color=>'purple'
      g.xaxis :min=>-2, :max=>10, :ticks=>2
      g.grid :show=>true, :color=>'#cccccc', :background_color=>'#eeeeee'
      g.serie :x1, :label=>'d1', :data=>10.times.map{|i| rand(10)+i}, :type=>:bar, :bars=>{:width=>5, :color=>'blue'}
      g.serie :x2, :label=>'d2', :data=>10.times.map{|i| rand(10)+i}, :type=>:scatter, :lines=>{:color=>'orange'}
      g.serie :x3, :label=>'d3', :data=>10.times.map{|i| rand(10)+i}, :type=>:line, :lines=>{:color=>'yellow', :width=>3, :shadow_depth=>20}, :markers=>{:show=>true, :color=>'red', :diameter=>10}
  end
end
rb.name="Graph"
puts rb.to_html
rb.save_html($base_dirname+'/graph.html')
