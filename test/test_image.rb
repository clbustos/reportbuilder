require(File.expand_path(File.dirname(__FILE__)+"/helper_test.rb"))

class TestReportbuilderImage < MiniTest::Unit::TestCase
  def setup
    @tmpdir=Dir::mktmpdir
    @rp=ReportBuilder.new(:no_name=>true, :directory=>@tmpdir)
    @datadir=File.dirname(__FILE__)+"/../data"
  end
  def teardown
    FileUtils.remove_entry_secure @tmpdir
  end
  def test_image_text
    @rp.add(ReportBuilder::ImageFilename.new(@datadir+"/sheep.jpg"))
    expected= <<-HERE
Test
+--------------------------------+
|          *********#**          |
|         ****#********#    *    |
|  * *  *********#*******     *  |
|           * ***  ***   *      *|
|     * *    WWW WW*     ***     |
|    ****   *WW* WWW *   **#*    |
|    ****   *        *   ****    |
|    *****  #       **  *#***    |
|    ****** **      *  *#****    |
|     ******        ********     |
|     *******   **   ******      |
|       **#***   * *******       |
|        ****#**  *#*****        |
|             **#*****           |
+--------------------------------+
    HERE
    if ReportBuilder.has_rmagick?
      real=@rp.to_s
      #expected=expected.gsub(/[^ ]/,'-')
      assert_match(/[^\s]{12}$/,real)
    else
      skip "Requires RMagick"
    end
  end
  def test_image_blob_jpg
    @rp.add(ReportBuilder::ImageFilename.new(@datadir+"/sheep.jpg"))
    out=File.read(@datadir+"/sheep.jpg")
    image_blob=ReportBuilder::ImageBlob.new(out, :type=>'jpg')
    @rp.add(image_blob)
    html=@rp.to_html
    assert(File.exists? image_blob.filename)
    assert_equal(out, File.read(image_blob.filename))
    assert_match(/img src='#{image_blob.url}'/, @rp.to_html)
    assert_match(/\\pict\\picw128\\pich112\\bliptag\d+\\jpegblip/, @rp.to_rtf)
  end
  def test_image_blob_svg
    svg='<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" width="200px" height="50px">
      <rect x="10" y="5" width="20" height="20" fill="blue" />
      </svg>'
    image_blob=ReportBuilder::ImageBlob.new(svg)
    assert_equal("svg", image_blob.type)
    @rp.add(image_blob)
    html=@rp.to_html
    assert(File.exists? image_blob.filename)
    assert_equal(svg, File.read(image_blob.filename))
    assert_match(/embed.+src='#{image_blob.url}'/, @rp.to_html)
    assert_match(/\\pict\\picw200\\pich50\\bliptag\d+\\pngblip/, @rp.to_rtf)
  end  
  def test_image_html
    @rp.add(ReportBuilder::ImageFilename.new(@datadir+"/sheep.jpg"))
    assert_match(/img src='images\/sheep.jpg'/, @rp.to_html)
  end
  def test_image_rtf
    @rp.add(ReportBuilder::ImageFilename.new(@datadir+"/sheep.jpg"))
    
    assert_match(/\\pict\\picw128\\pich112\\bliptag\d+\\jpegblip/, @rp.to_rtf)
  end
end
