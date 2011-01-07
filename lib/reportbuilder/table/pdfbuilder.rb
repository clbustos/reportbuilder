require 'text-table'
require 'prawn/table'
class ReportBuilder
  class Table
    # Text Builder for ReportBuilder::Table objects.
    # 
    # Uses Aaron Tinio's text-table gem[http://github.com/aptinio/text-table]
    
    class PdfBuilder < ElementBuilder
      def generate()
        t=@element
        @pdf=@builder.pdf
        @rowspans=[]
        if !t.nil? and t.name!=""
          @pdf.pad_top 10 do
            @pdf.text t.name, {:size=>12, :align=>:center} 
          end
        end
        return if t.header.size+t.rows.size==0
        has_header=t.header.size>0
        @pdf.pad(10) do 
          if has_header
            t_options=t.options.merge({:headers=>t.header, :align_headers=>:center})
            @pdf.table(t.rows.map{|row| parse_row(row)}, t_options) do
              row(0).style(:font_style => :bold, :background_color => 'cccccc')
            end
          else
            @pdf.table(t.rows.map{|row| parse_row(row)}, t.options) 
          end
        end
      end
      # Parse a row
      def parse_row(row)
        if row==:hr
          []
        else
          row
        end
      end
    end
  end
end
