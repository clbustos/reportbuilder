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
        out+="
<script>
$.jqplot('graph_#{anchor}', #{@builder.parse_js(@element.series_data)},
"+@builder.parse_js(jqplot_options)+");
</script>"
        
        @builder.html(out)
      end
      def jqplot_options
        opts=Hash.new
        opts[:title]=@element.title
        opts[:series]=series_options
        opts[:axesDefaults]=axes_defaults if @element.axes_defaults.size>0
        if @element.xaxis.size>0 or @element.yaxis.size>0
          opts[:axes]={:xaxis=>xaxis, :yaxis=>yaxis}
        end
        opts[:seriesDefaults]= series_defaults if @element.series_defaults.size>0
        opts[:legend]=legend  if @element.legend.size>0
        opts[:grid]=grid if @element.grid.size>0
        opts
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
      def axes_defaults
        hash_to_camel(@element.axes_defaults)
      end
      def xaxis
        hash_to_camel(@element.xaxis)
      end
      def yaxis
        hash_to_camel(@element.yaxis)
      end
      def legend
        lo=@element.legend
        lo[:location]=lo.delete(:position) if lo[:position] 
        hash_to_camel(lo)
      end
      def series_defaults
        series_js(@element.series_defaults)
      end
      def grid
        replace={:show=>:drawGridLine, :color=>:gridLineColor, :background_color=>:background}
        out=Hash.new
        @element.grid.each do |k,v|
          if replace.include? k
            out[replace[k]]=v
          else
            out[to_camel(k)]=v
          end
        end
        out
      end
      def hash_to_camel(h)
        out=Hash.new
        h.each do |k,v|
          out[to_camel(k)]=v
        end
        out
      end
      def to_camel(k)
        k.to_s.gsub(/_([a-z])/) {|s| s.upcase[1,1]}.to_sym
      end
      def series_js(in_opt)
        out_opt=Hash.new
        out_opt[:markerOptions]=Hash.new
        out_opt[:rendererOptions]=Hash.new
        in_opt.each_pair do |k,v|
          case k
            when :type
              set_type(out_opt, v)
            when :lines
              out_opt[:showLines]=v[:show] if v[:show]              
              v.each do |k1,v1|
                out_opt[to_camel(k1)]=v1
              end
            when :markers
              out_opt[:showMarker]=v[:show] if v[:show]
              v.each do |k1,v1|
                out_opt[:markerOptions][to_camel(k1)]=v1
              end
            when :bars
              v.each do |k1,v1|
                k1=("bar_"+k1.to_s) if [:padding, :margin, :direction, :width].include? k1
                out_opt[:rendererOptions][to_camel(k1)]=v1
              end              
            when :color
              if in_opt[:type]
                set_color(in_opt[:type], out_opt,v)
              else
                out_opt[k]=v
              end
            else
              out_opt[k]=v
          end
        end
        out_opt
      end
      def set_color(t,out_opt,v)
        case t
          when :line
            out_opt[:color]=v
          when :scatter
            out_opt[:markerOptions][:color]=v
          when :bar
            out_opt[:rendererOptions][:color]=v
        end
      end

      # Transform data options on jqPlot ones
      def series_options
        @element.series_options.map do |in_opt|
          series_js(in_opt)
        end
      end
    end
  end
end
