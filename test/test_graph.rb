require(File.expand_path(File.dirname(__FILE__)+"/helper_test.rb"))

class TestReportbuilderGraph < MiniTest::Unit::TestCase
  def test_init_without_block
    width=rand(200)
    height=rand(200)
    graph=ReportBuilder::Graph.new(:name=>"Aa",:height=>height,:width=>width)
    assert_equal('Aa', graph.name)
    assert_equal(width, graph.width)
    assert_equal(height, graph.height)
  end
  def test_with_block
    width=rand(200)
    height=rand(200)
    graph=ReportBuilder::Graph.new do |g|
      g.name = 'Aa'
      g.width width
      g.height=height
    end
    assert_equal('Aa', graph.name)
    assert_equal(width, graph.width)
    assert_equal(height, graph.height)
  end
  def test_series_definitions
    x1_data=[[1,1],[2,2.5],[3,3.5],[4,4.5],[5,5.5]]
    x2_data=[[1,5],[2,4],[3,3],[4,2],[5,1]]
    graph=ReportBuilder::Graph.new do |g|
      g.data 1, 1,2.5,3.5,4.5,5.5
      g.serie_options 1, :color=>'blue'
      g.serie "x2", :data=>x2_data, :color=>'red'
    end
    exp_data={1=>x1_data, 'x2'=>x2_data}
    exp_options={
      1=>{:color=>'blue'},
      "x2"=>{:color=>'red'}
    }
    assert_equal(exp_data, graph.series_data_hash)
    assert_equal(exp_options, graph.series_options_hash)
    assert_equal([1, "x2"],graph.series_id)
    assert_equal(x2_data, graph.data('x2'))
    assert_equal([x1_data,x2_data], graph.series_data)
    assert_equal([{:color=>'blue'}, {:color=>'red'}], graph.series_options)
  end  
end
