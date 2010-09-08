class ReportBuilder
  class Graph
    # @element and @builder
    class HtmlFlot < ElementBuilder
      def generate()
        @builder.js(ReportBuilder::DATA_DIR+"/flot/excanvas.min.js")

        @builder.js(ReportBuilder::DATA_DIR+"/flot/jquery.min.js")
        @builder.js(ReportBuilder::DATA_DIR+"/flot/jquery.flot.min.js")
        anchor=@builder.graph_entry(@element.name)
        out="<a name='#{anchor}'></a><div id='graph_#{anchor}' style='width:#{@element.width}px; height:#{@element.height}px'> </div>"
        out+="<script>
          $.plot($('#graph_#{anchor}'),
          #{series_options}
          
          );"
        
        
        
        out+="</script>"
        
        @builder.html(out)
      end
      def set_type(opt,v)
        case v
        when :line
        when :pie
          raise "doesn't supported on flot"
        when :scatter
          opt[:lines][:show]=false
          opt[:points][:show]=true

        when :bar
          opt[:lines][:show]=false
          opt[:bars][:show]=true

        else
          raise "Type doesn't exists"
        end
      end
      # Transform data options on jqPlot ones
      def series_options
        dv=@element.data_values
        i=0
        own_options=@element.data_options.map do |in_opt|
          out_opt=Hash.new
          out_opt[:data]=dv[i]
          i+=1
          out_opt[:lines]=Hash.new
          out_opt[:points]=Hash.new
          out_opt[:bars]=Hash.new
          in_opt.each_pair do |k,v|
            case k
              when :type
                
                set_type(out_opt, v)
              when :line_width
                out_opt[:lines][:lineWidth]=v
              when :show_marker
                out_opt[:points][:show]=v
              when :show_line
                out_opt[:lines][:show]=v
                
              when /marker_(.+)/
                mo=$1                
                if mo=~/(.+)_(.+)/
                  out_opt[:points]["#{$1}#{$2.capitalize}".to_sym]=v
                elsif mo=='size'
                  out_opt[:points][:radius]=v
                else
                  out_opt[:points][mo.to_sym]=v
                end
              when /(.+)_(.+)_(.+)/
                out_opt["#{$1}#{$2.capitalize}#{$3.capitalize}".to_sym]=v
              when /(.+)_(.+)/
                out_opt["#{$1}#{$2.capitalize}".to_sym]=v

              when :line_width
                out_opt[:lines][:lineWidth]=v
              else
                out_opt[k]=v
            end
          end
          out_opt
          
        end
        @builder.parse_js(own_options)
      end
      
    end
  end
end
