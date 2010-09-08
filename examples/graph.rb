$:.unshift(File.dirname(__FILE__)+"/../lib")
require "reportbuilder"    
rb=ReportBuilder.new do |rb|
  rb.graph(:name=>"Graph", :html_engine=>:flot) do |g|
    g.leyend_show true
    g.data :x1, 1,2,4,8 # Automatic asignation of x axis
    g.data :x2, [2.2,3],[1.5,2], [4,5], [2,10] # Manual asignation of x axis
    
    g.xaxis :label=>"X axis", :autoscale=>true
    g.yaxis :label=>"Y axis", :autoscale=>true
    
    g.options :x1, :type=>:bar, :label=>"Data 1", :color=>"blue"

    g.options :x2, :type=>:line, :show_marker=>true, :show_line=>true, :shadow=>false, :label=>"Data 2", :label_show=>true, :color=>"red",  :line_width=>1,:marker_style=>'square', :marker_size=>20, :marker_color=>'orange', :marker_shadow_angle=>90
    
  end
end
rb.name="Graph"
puts rb.to_html
