$:.unshift(File.dirname(__FILE__)+"/../lib")
require "reportbuilder"
$base_dirname=File.dirname(__FILE__)
rb=ReportBuilder.new(:directory=>$base_dirname) do |rb|
  rb.graph(:name=>"Graph", :html_engine=>:flot) do |g|
   g.series_defaults :color=>'red', :bars=>{:width=>5}
   g.legend :show=>true, :position=>'nw', :background_color=>'yellow'
      g.xaxis :min=>-2, :max=>10, :ticks=>2
      g.grid :show=>true, :color=>'#cccccc', :background_color=>'#eeeeee'
      g.serie :x1, :label=>'d1', :data=>10.times.map{|i| rand(10)}, :type=>:bar, :bars=>{:width=>30, :color=>'blue'}
      g.serie :x2, :label=>'d2', :data=>10.times.map{|i| rand(10)}, :type=>:scatter, :lines=>{:width=>5, :fill=>false, :shadow_depth=>5, :fill_color=>'yellow'}
      g.serie :x3, :label=>'d3', :data=>10.times.map{|i| rand(10)}, :type=>:line, :lines=>{:width=>5, :fill=>false, :shadow_depth=>20, :fill_color=>'yellow'}      
  end
end
rb.name="Graph"
puts rb.to_html
rb.save_html($base_dirname+'/graph.html')
