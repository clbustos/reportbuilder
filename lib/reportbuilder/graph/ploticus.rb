require 'tempfile'
require 'fileutils'
class ReportBuilder
  class Graph
    class Ploticus < ElementBuilder
    attr_reader :path
    def initialize(builder, element)
      super
      # Create path for image
      @script=Tempfile.new("script_#{@element.number}.pl")
      @image=Tempfile.new("graph_#{@element.number}.png")
      @out=""
    end

      def generate()
        @element.define_xy_ranges
        areadef 
        series
        @script.write(@out)
        `ploticus -f #{@script.path} -png -o #{@image.path}`
        @script.close

        @builder.image(@image.path)
        @image.close
      end
      def areadef
        @out << <<EOF
#proc areadef
xrange: #{@element.xmin} #{@element.xmax}
yrange: #{@element.xmax} #{@element.ymax}

EOF
    
      end
    end
  end
end