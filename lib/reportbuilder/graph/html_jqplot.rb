class ReportBuilder
  class Graph
    # @element and @builder
    class HtmlJqplot < ElementBuilder
      def generate()
        @builder.js(ReportBuilder::DATA_DIR+"/jqplot/excanvas.min.js")

        @builder.js(ReportBuilder::DATA_DIR+"/jqplot/jquery-1.4.2.min.js")
        @builder.js(ReportBuilder::DATA_DIR+"/jqplot/jquery.jqplot.min.js")
        @builder.css(ReportBuilder::DATA_DIR+"/jqplot/jquery.jqplot.css")
        anchor=@builder.graph_entry(@element.name)
        out="<a name='#{anchor}'></a><div id='graph_#{anchor}' style='width:#{@element.width}px; height:#{@element.height}px'> </div>"
        out+="<script>
          $.jqplot('graph_#{anchor}', #{@builder.parse_js(@element.data_values)},
        { title: #{@builder.parse_js(@element.name)},
        
          series: 
          #{series_options}
          
        
        });"
        
        
        
        out+="</script>"
        
        @builder.html(out)
      end
      def set_type(opt,v)
        case v
        when :line
        when :pie
          @builder.js(ReportBuilder::DATA_DIR+"/jqplot/plugins/jqplot.pieRenderer.min.js")
          opt[:renderer]="$.jqplot.PieRenderer".to_sym
        when :scatter
          opt[:showLine]=false
          opt[:showMarker]=true
        when :bar
          @builder.js(ReportBuilder::DATA_DIR+"/jqplot/plugins/jqplot.categoryAxisRenderer.min.js")
          @builder.js(ReportBuilder::DATA_DIR+"/jqplot/plugins/jqplot.barRenderer.min.js")
          opt[:renderer]="$.jqplot.BarRenderer".to_sym
        else
          raise "Type doesn't exists"
        end
      end
      # Transform data options on jqPlot ones
      def series_options
        own_options=@element.data_options.map do |in_opt|
          out_opt=Hash.new
          marker_options={}
          renderer_options={}
          in_opt.each_pair do |k,v|
            case k
              when :type
                set_type(out_opt, v)
              when /marker_(.+)/
                mo=$1
                if mo=~/(.+)_(.+)/
                  marker_options["#{$1}#{$2.capitalize}".to_sym]=v
                else
                  marker_options[mo.to_sym]=v
                end
              when /(.+)_(.+)_(.+)/
                out_opt["#{$1}#{$2.capitalize}#{$3.capitalize}".to_sym]=v
              when /(.+)_(.+)/
                out_opt["#{$1}#{$2.capitalize}".to_sym]=v

              when :line_width
                out_opt[:lineWidth]=v
              else
                out_opt[k]=v
            end
          end
          out_opt[:markerOptions]=marker_options
          out_opt[:rendererOptions]=renderer_options
          
          out_opt
          
        end
        @builder.parse_js(own_options)
      end
      
    end
  end
end
