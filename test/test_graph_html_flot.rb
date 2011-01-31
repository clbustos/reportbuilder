require(File.expand_path(File.dirname(__FILE__)+"/helper_test.rb"))
require 'json'
class TestReportbuilderGraphHtmlFlot < MiniTest::Unit::TestCase
  def setup
    @tmpdir=Dir::mktmpdir
    @datadir=File.dirname(__FILE__)+"/../data"
    @rp_name="Graph Test"
    @rp=ReportBuilder.new(:name=>@rp_name, :directory=>@tmpdir)
    @graph=ReportBuilder::Graph.new(:html_engine=>:flot) do |g|
      g.series_defaults :color=>'red', :bars=>{:width=>5}
      g.legend :show=>true, :position=>'e', :background_color=>'yellow'
      g.xaxis :min=>-2, :max=>10, :ticks=>2
      g.grid :show=>true, :color=>'#cccccc', :background_color=>'#eeeeee'
      g.serie :x1, :data=>[1,2,1.5,3,2], :type=>:bar, :bars=>{:width=>30, :color=>'blue'}
      g.serie :x2, :data=>[3,2,1,2,1], :lines=>{:width=>5, :fill=>false, :shadow_depth=>5, :fill_color=>'yellow'}, :markers=>{:show=>true,:color=>'orange', :radius=>5, :shadow=>true, :shadow_depth=>2}
    end
  end
  def test_smoke
    @tempfile=Tempfile.new("test.html")
    @path=@tempfile.path
    @rp.add(@graph)
    @rp.save_html(@path)
    assert(File.exists? @path)
    @tempfile.close    
  end
  def test_js
    require 'reportbuilder/graph/html_flot'
    html = ReportBuilder::Builder::Html.new(nil, {:name=>'hola'})
    jqplot_builder = ReportBuilder::Graph::HtmlFlot.new(html, @graph)
    jo=jqplot_builder.flot_options
    assert_equal('red', jo[:series][:color])
    assert(jo[:series][:bars].nil?)
    assert_equal('#cccccc', jo[:grid][:color])
  end

end
