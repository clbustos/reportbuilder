class ReportBuilder
  class Graph
    # Flot Wrapper
    class HtmlFlot < ElementBuilder
      def generate()
        @builder.js(ReportBuilder::DATA_DIR+"/flot/excanvas.min.js")

        @builder.js(ReportBuilder::DATA_DIR+"/flot/jquery.min.js")
        @builder.js(ReportBuilder::DATA_DIR+"/flot/jquery.flot.min.js")
        
        anchor=@builder.graph_entry(@element.name)
        out="<a name='#{anchor}'></a><div id='graph_#{anchor}' style='width:#{@element.width}px; height:#{@element.height}px'> </div>"
        out << "<script>\n$.plot($('#graph_#{anchor}'),"
        out << @builder.parse_js(flot_series)+",\n" 
        out << @builder.parse_js(flot_options)+"\n);"
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
        when :histogram
          opt[:lines][:show]=false
          opt[:bars][:show]=true
          opt[:bars][:align]="center"
        else
          raise "Type doesn't exists"
        end
      end
      
      
      def hash_to_camel(h)
        out=Hash.new
        h.each do |k,v|
          out[to_camel(k)]=v
        end
        out
      end
      def to_camel(k)
        k.to_s.gsub(/_([a-z])/) {|s| s.upcase[1]}.to_sym
      end
      
      def flot_options
        opts=Hash.new
        opts[:title]=@element.title
        opts[:axesDefaults]=axes_defaults if @element.axes_defaults.size>0
        opts[:xaxis]=xaxis
        opts[:yaxis]=yaxis
        opts[:seriesDefaults]= series_defaults if @element.series_defaults.size>0
        opts[:legend]=legend  if @element.legend.size>0
        opts[:grid]=grid if @element.grid.size>0
        opts
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
        lo.delete(:position) if lo[:position] and !["ne","nw","se","sw"].include? lo[:position]
        hash_to_camel(lo)
      end
      def series_defaults
        series_js(@element.series_defaults)
      end
      def grid
        replace={}
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
      def series_js(in_opt)
        out_opt=Hash.new        
        out_opt[:lines]=Hash.new
        out_opt[:points]=Hash.new
        out_opt[:bars]=Hash.new
        in_opt.each_pair do |k,v|
          case k
            when :type
              set_type(out_opt, v)
            when :markers
              out_opt[:points]=v
            else
              if out_opt[k] and out_opt[k].is_a? Hash
                out_opt[:shadowSize]=v[:shadow_depth] if v[:shadow_depth]
                out_opt[k]=out_opt[k].merge(v)
              else
                out_opt[k]=v
              end
          end
        end
        [:lines, :points, :bars].each do |v|
          out_opt.delete(v) if out_opt[v].size==0
        end
        out_opt
      end
      # Transform data options on jqPlot ones
      def flot_series
        dv=@element.series_data
        i=0
        own_options=@element.series_options.map do |in_opt|
          out_opt=Hash.new
          out_opt[:data]=dv[i]
          i+=1
          out_opt.merge(series_js(in_opt))
        end
        own_options
      end
      
    end
  end
end
