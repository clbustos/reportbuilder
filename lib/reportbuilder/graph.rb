class ReportBuilder
  # Creates a Graph. API based on:
  # * jqPlot: [http://www.jqplot.com/]
  # 
  # == API Reference
  # All options could be not available on specifics builder. 
  # See documentation and source code for specific information
  # * height
  # * width
  # * data: Array for a specific data serie. The first parameter 
  #   should be the id, and the next elements could be single values, 
  #   with automatic
  #   asignation on x axis (from 1 to n), or an array of values. Normally,
  #   they correspond to x, y and z axis, but may change according to specific
  #   series type
  # * series_defaults: Options for all series. The options are:
  #   * type: could be :line, :bar, :scatter, :pie. Depending on engine,
  #           is a shorthand designed to set several options at once or set
  #           the 'real' type of plot
  #   * label: String
  #   * color: String
  #   * lines: Hash
  #     * show: boolean
  #     * color: String
  #     * width: integer
  #     * fill: boolean
  #     * fill_color: string
  #     * shadow: boolean
  #     * shadow_angle
  #     * shadow_offset
  #     * shadow_depth
  #     * shadow_alpha  
  #   * markers: Hash
  #     * show: boolean
  #     * color: boolean
  #     * style: style
  #     * line_width
  #     * size: integer (diameter)
  #     * diameter:
  #     * radius:
  #     * shadow: boolean
  #     * shadow_angle
  #     * shadow_offset
  #     * shadow_depth
  #     * shadow_alpha
  #   * bars: Hash
  #     * color
  #     * width
  #     * padding
  #     * margin
  #     * direction
  #     * align: 'left' or 'center'
  # * serie_options: Options for a specific serie. The first argument should
  #   be the id of serie, and the second parameter should be a hash with 
  #   options according to series_options
  # * serie: Shorthand for :data and :serie_options. The first element is the 
  #   id, the second a hash with options for serie, including :data key to
  #   assign data to a serie.
  # * legend: hash of options
  #   * show
  #   * position:
  #   * margin
  #   * background_color
  # * title
  #   * show
  #   * text: by default, equal to name of element
  # * axes_defaults: hash of options
  #   * show
  #   * min
  #   * max
  #   * autoscale
  #   * label_width
  #   * label_height
  #   * ticks: number of ticks or array
  # * xaxes: Same as axes_defaults
  # * yaxes: Same as axes_defaults
  # * grid
  #   * show
  #   * color
  #   * background_color
  #   * tick_color
  #   * border_width
  #   * border_color
  #   * shadow: boolean
  #   * shadow_angleel
  #   * shadow_offset
  #   * shadow_depth
  #   * shadow_alpha
  
  # == Usage
  # graph=ReportBuilder::Graph.new(:name=>"Graph", ) do |g|
  #   g.serie :x1, :data=>[1,2,3,4], :label=>"Data 1" # Automatic asignation of x axis
  #   g.data :x2, :data=>[[1,2],[2,3],[4,5]], :label=>"Data 2" # Manual asignation of x axis
  #   g.xaxis :label=>"X axis", :autoscale=>true # jqPlot like asignation
  # end
  class Graph    
    # Allows to define an reader/writer function
    # Without parameters, retrieve the value for a instance variable
    # With parameters, set the value for instance variable
    def self.attr_accessor_dsl(*attr)
      attr.each  do |sym| 
        sym_w_sm=sym.to_s.gsub(":","")
        define_method(sym) do |*args|
          if args.size==0
            instance_variable_get("@#{sym_w_sm}")
          else
            instance_variable_set("@#{sym_w_sm}", args[0])
          end
        end
        
        define_method(sym.to_s+"=") do |*args|
          instance_variable_set("@#{sym_w_sm}", args[0])
        end
      end
    end

    @@n=1 # :nodoc:
    attr_reader :name
    attr_reader :number, :series_data_hash, :series_options_hash
    
    attr_accessor_dsl :height, :width, :series_defaults, :title, :xaxis, :yaxis, :grid, :html_engine, :generic_engine, :legend, :axes_defaults
    attr_reader :xmin,:xmax,:ymin, :ymax
    def initialize(options=Hash.new, &block)
      @number=@@n
      @@n+=1
      if !options.has_key? :name
        @name="Graph #{@@n}"
      else
        @name=options.delete(:name)
      end
      @series_data_hash=Hash.new
      @series_options_hash=Hash.new
      @series_defaults=Hash.new
      @xaxis=Hash.new
      @yaxis=Hash.new
      @grid=Hash.new
      @legend=Hash.new
      @axes_defaults=Hash.new
      @title={:text=>@name}
      default_options={
        :width=>600,
        :height=>400,
        :html_engine=>:jqplot,
        :generic_engine=>:rchart
      }
      @options=default_options.merge(options)
      @options.each {|k,v|
        self.send("#{k}=",v) if self.respond_to? k
      }
      
      if block
        block.arity<1 ? self.instance_eval(&block) : block.call(self)
      end
    end
    def name=(v)
      @name=v
      @title[:text]=v unless @title[:text]
    end
    def series_id
      @series_data_hash.keys.sort {|a,b| a.to_s<=>b.to_s}
    end
    def series_data
      series_id.map {|v|
        @series_data_hash[v]
      }
    end
    def series_options
      series_id.map {|v|
        @series_options_hash[v]
      }
    end
    
    def data(name, *d)
      i=0
      if d.size==0
        @series_data_hash[name]
      else
        @series_data_hash[name]=d.map {|v|
          i+=1
          if v.is_a? Array
            v
          else
            [i,v]
          end
        }
      end
    end
    def set_marker_size(h)
      d=h[:markers][:diameter]  if h[:markers][:diameter]
      d=h[:markers][:size]      if h[:markers][:size]
      d=2*h[:markers][:radius]  if h[:markers][:radius]
      h[:markers][:diameter]=d
      h[:markers][:radius]=d/2.0
      h[:markers][:size]=d
    end
    def serie_options(name, h)
      set_marker_size(h) if h[:markers] and (h[:markers].keys & [:size, :radius, :diameter]).size > 0
      @series_options_hash[name]=h
    end
    def serie(name,d)
      raise "You should define :data key" unless d[:data]
      da=d.delete(:data)
      data(name,*da)
      serie_options(name,d)
    end
    
    def actuals_minmax
      if @actuals_minmax.nil?
        @actuals_minmax=Hash.new
        series_data.each do |data|
          data.each do |v|
            @actuals_minmax[:xmin]||=v[0]
            @actuals_minmax[:xmax]||=v[0]
            @actuals_minmax[:ymin]||=v[1]
            @actuals_minmax[:ymax]||=v[1]
            @actuals_minmax[:xmin]=v[0] if @actuals_minmax[:xmin]>v[0]
            @actuals_minmax[:xmax]=v[0] if @actuals_minmax[:xmax]<v[0]
            @actuals_minmax[:ymin]=v[1] if @actuals_minmax[:ymin]>v[1]
            @actuals_minmax[:ymax]=v[1] if @actuals_minmax[:ymax]<v[1]
          end
        end
      end
      @actuals_minmax
    end
    
    def define_xy_ranges
      @xmin=xaxis[:min] if xaxis[:min]
      @xmax=xaxis[:max] if xaxis[:max]
      @ymin=yaxis[:min] if yaxis[:min]
      @ymin=yaxis[:max] if yaxis[:max]
      @xmin||=actuals_minmax[:xmin]
      @xmax||=actuals_minmax[:xmax]
      @ymin||=actuals_minmax[:ymin]
      @ymax||=actuals_minmax[:ymax]
    end
    

    
    def report_building_html(builder)
      require "reportbuilder/graph/html_#{html_engine}"
      klass=("Html"+html_engine.to_s.capitalize).to_sym
      graph_builder=ReportBuilder::Graph.const_get(klass).new(builder, self)
      graph_builder.generate
    end
    def report_building(builder)
      require "reportbuilder/graph/#{generic_engine}"
      klass=(generic_engine.capitalize).to_sym
      graph_builder = ReportBuilder::Graph.const_get(klass).new(builder, self)
      graph_builder.generate
    end
  end
end