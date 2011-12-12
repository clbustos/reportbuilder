require 'reportbuilder/builder'
require 'reportbuilder/table'
require 'reportbuilder/section'
require 'reportbuilder/image'
require 'reportbuilder/graph'

# = Report Abstract Interface.
# Creates text, html,pdf and rtf output, based on a common framework.
#
# == Use
# 
# 1) Using generic ReportBuilder#add, every object will be parsed using methods report_building_FORMAT, #report_building or #to_s
# 
#  require "reportbuilder"    
#  rb=ReportBuilder.new
#  rb.add(2) #  Int#to_s used
#  section=ReportBuilder::Section.new(:name=>"Section 1")
#  table=ReportBuilder::Table.new(:name=>"Table", :header=>%w{id name})
#  table.row([1,"John"])
#  table.hr
#  table.row([2,"Peter"])
#  section.add(table) #  Section is a container for other methods
#  rb.add(section) #  table have a #report_building method
#  rb.add("Another text") #  used directly
#  rb.name="Text output"
#  puts rb.to_text
#  rb.name="Html output"
#  puts rb.to_html
# 
# 2) Using a block, you can control directly the builder
# 
#  require "reportbuilder"    
#  rb=ReportBuilder.new do
#   text("2")
#   section(:name=>"Section 1") do
#    table(:name=>"Table", :header=>%w{id name}) do
#     row([1,"John"])
#     hr
#     row([2,"Peter"])
#    end
#   end
#   preformatted("Another Text")
#  end
#  rb.name="Text output"
#  puts rb.to_text
#  rb.name="Html output"
#  puts rb.to_html
class ReportBuilder
  attr_reader :elements
  # Name of report
  attr_accessor :name
  # Doesn't print a title if set to true
  attr_accessor :no_title
  # ReportBuilder version
  VERSION = '1.4.2'
  DATA_DIR=File.dirname(__FILE__)+"/../data"
  FormatNotFound=Class.new(Exception)
  # Available formats
  def self.builder_for(format)
    format=format.to_s.downcase
    Builder.inherited_classes.find {|m| m.code.include? format} 
  end
  def self.has_rmagick?
    begin
      require 'RMagick'
      true
    rescue LoadError
      false
    end
  end
  # Generates and optionally save the report on one function
  # 
  # * options= Hash of options
  #  * :filename => name of file. If not provided, returns output
  #  * :format => format of output. See Builder subclasses
  # * &block: block executed inside builder 
  def self.generate(options=Hash.new, &block)
    options[:filename]||=nil
    options[:format]||=self.get_format_from_filename(options[:filename]) if options[:filename]    
    options[:format]||="text"
    
    file=options.delete(:filename)
    format=options.delete(:format)
    rb=ReportBuilder.new(options)
    rb.add(block)
    begin
      builder=builder_for(format).new(rb, options)
    rescue NameError  => e
      raise ReportBuilder::FormatNotFound.new(e)
    end
    builder.parse
    out=builder.out
    unless file.nil?
      File.open(file,"wb") do |fp|
        fp.write out
      end
    else
      out
    end
  end
  def self.get_format_from_filename(filename)
    filename=~/\.(\w+?)$/
    $1
  end
  # Create a new Report
  def initialize(options=Hash.new, &block)
    options[:name]||="Report "+Time.now.to_s
    @no_title=options.delete :no_title
    @name=options.delete :name 
    @name=@name.to_s
    @options=options
    @elements=Array.new
    add(block) if block
  end
  # Add an element to the report.
  # If parameters is an object which respond to :to_reportbuilder,
  # this method will called.
  # Otherwise, the element itself will be added
  def add(element)
    @elements.push(element)
    self
  end
  # Returns an Html output
  def to_html
    gen = Builder::Html.new(self,@options)
    gen.parse
    gen.out
  end
  # Returns a RTF output
  def to_rtf
    gen = Builder::Rtf.new(self, @options)
    gen.parse
    gen.out
  end
  def to_pdf
    gen = Builder::Pdf.new(self, @options)
    gen.parse
    gen.out
  end
  def save(filename)
    format=(self.class).get_format_from_filename(filename)
    send("save_#{format}", filename)
  end
  # Save a rtf file
  def save_rtf(filename)
    gen = Builder::Rtf.new(self,@options)
    gen.parse
    gen.save(filename)
  end
  # Save an html file
  def save_html(file)
    options=@options.dup
    options[:directory]=File.dirname(file)
    gen=Builder::Html.new(self, options)
    gen.parse
    gen.save(file)
  end
  # Save a pdf file
  def save_pdf(file)
    options=@options.dup
    gen=Builder::Pdf.new(self, options)
    gen.parse
    gen.save(file)
  end  

  # Returns a Text output
  def to_text()
    gen=Builder::Text.new(self, @options)
    gen.parse 
    gen.out
  end
  def save_text(file)
    gen=Builder::Text.new(self, @options)
    gen.parse
     gen.save(file)    
  end
  
  alias_method :to_s, :to_text
end
