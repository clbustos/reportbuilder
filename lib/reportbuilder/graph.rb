class ReportBuilder
  # Creates a Graph. API based on:
  # * jqPlot: [http://www.jqplot.com/]
  # * SVG::Graph
  # 
  # Usage
  # graph=ReportBuilder::Graph.new(:name=>"Graph", ) do |g|
  #   g.data :x1, 1,2,3,4 # Automatic asignation of x axis
  #   g.data :x2, [1,2],[2,3],[4,5] # Manual asignation of x axis
  #   g.xaxis :label=>"X axis", :autoscale=>true # jqPlot like asignation
  #   g.yaxis_label 'Y axis'
  #   g.yaxis_autoscale true # standard asignation
  #   g.options :x1, :label=>"Data 1"
  #   g.options :x2, :label=>"Data 2"
  # end
  class Graph    
    def self.attr_accessor_dsl(*attr)
      attr.each  do |sym| 
        sym_w_sm=sym.to_s.gsub(":","")
        define_method(sym) do |*args|
          if args.size==0
            instance_variable_get("@#{sym_w_sm}")
          else
            instance_variable_set("@#{sym_w_sm}", args)
          end
        end
        
        define_method(sym.to_s+"=") do |*args|
          instance_variable_set("@#{sym_w_sm}", args)
        end
        
      end
    end

    @@n=1 # :nodoc:
    attr_accessor :name
    attr_reader :number, :datas, :options
    
    attr_accessor_dsl :height, :width, :xaxis_label, :xaxis_autoscale, :yaxis_label, :yaxis_autoscale, :leyend_show, :html_engine
    
    def initialize(options=Hash.new, &block)
      @number=@@n
      @@n+=1
      if !options.has_key? :name
        @name="Graph #{@@n}"
      else
        @name=options[:name]
      end
      default_options={
        :width=>600,
        :height=>400,
        :html_engine=>:jqplot
      }
      @options=default_options.merge(options)
      @width=@options[:width]
      @height=@options[:height]
      @html_engine=@options[:html_engine]
      @datas=Hash.new
      @options=Hash.new
      @xaxis_label=""
      @xaxis_autoscale=true
      @yaxis_label=""
      @yaxis_autoscale=true
      if block
        block.arity<1 ? self.instance_eval(&block) : block.call(self)
      end
    end
    
    
    def data_values
      @datas.sort.map {|v|
        v[1]
      }
    end
    def data_options
      @datas.keys.sort.map {|v|
        @options[v]
      }
    end
    
    def data(name, *d)
      i=0
      if d.size==0
        @datas[name]
      else
        @datas[name]=d.map {|v|
          i+=1
          if v.is_a? Array
            v
          else
            [i,v]
          end
        }
      end
    end
    def options(name, values)
      @options[name]=values
    end
    
    def xaxis(opts)
      @xaxis_label=opts[:label] if opts[:label]
      @xaxis_autoscale=opts[:autoscale] if opts[:autoscale]
    end
    def yaxis(opts)
      @yaxis_label=opts[:label] if opts[:label]
      @yaxis_autoscale=opts[:autoscale] if opts[:autoscale]
    end
    
    def report_building_html(builder)
      require "reportbuilder/graph/html_#{html_engine}"
      klass=("Html"+html_engine.capitalize).to_sym
      graph_builder=ReportBuilder::Graph.const_get(klass).new(builder, self)
      graph_builder.generate
    end
    
  end
end
