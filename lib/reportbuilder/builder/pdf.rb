require 'prawn'
require 'pp'
class ReportBuilder
  class Builder
    # Rtf Builder.
    # Based on Prawn[http://prawn.majesticseacreature.com/]
    # 
    class Pdf < Builder
      # Pdf object.
      attr_accessor :pdf
      # Creates a new Pdf object
      # Params:
      # * <tt>builder</tt>: A ReportBuilder::Builder object or other with same interface
      # * <tt>options</tt>: Hash of options.
      def initialize(builder, options)
        super
        @pdf=Prawn::Document.new(options)
        @pdf.font_size=@options[:font_size]
      end
      
      def self.code
        %w{pdf}
      end
      def parse
         unless @builder.no_title
           header(0,@builder.name)
         end
        parse_cycle(@builder)
      end
      
      def default_options
        {
          :font_size=>12
        }
      end
      # Add a paragraph of text.
      def text(t)
        @pdf.text(t)
      end
      # Add a header of level <tt>level</tt> with text <tt>t</tt>
      # Level works similar to h
      def header(level, t)
        @pdf.text t, :size=>15-level
      end
      # Add preformatted text. 
      def preformatted(t)
        @pdf.font("Courier") do 
          @pdf.text t 
        end
      end
      # Returns pdf code for report
      def out
        @pdf.render
      end
      # Save pdf file
      def save(filename)
        @pdf.render_file(filename)
      end
      # Do nothing on this builder 
      def html(t)
        # Nothing
      end
    end
  end
end
