class ReportBuilder
  class Graph
    # @element and @builder
    class HtmlPloticus < ElementBuilder
      def generate()
        ploticus=ReportBuilder::Graph::Ploticus.new(@builder,@element)
        ploticus.generate
      end
    end
  end
end