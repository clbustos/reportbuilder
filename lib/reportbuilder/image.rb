require 'digest/md5'
class ReportBuilder
  # Abstract class for an image
  class Image
    @@n=1
    attr_accessor :name
    attr_accessor :alt
    attr_accessor :chars
    attr_accessor :font_rows
    attr_accessor :font_cols
    attr_accessor :width
    attr_accessor :height
    attr_accessor :svg_raster
    attr_accessor :type
    attr_reader :filename
    attr_reader :url
    attr_reader :id
    
    def initialize(options=Hash.new)
      @id=Digest::MD5.hexdigest(Time.new.to_f.to_s)      
      @type=nil
      if !options.has_key? :name
        @name="Image #{@@n}"
        @@n+=1
      else
        @name=options.delete :name
      end
      
      default_options={
        :alt=>@name,
        :chars => [ 'W', 'M', '$', '@', '#', '%', '^', 'x', '*', 'o', '=', '+',
        ':', '~', '.', ' ' ],
        :font_rows => 8,
        :font_cols => 4,
        :width=>nil,
        :height=>nil,
        :svg_raster=>false
      }
      @options=default_options.merge options
      @options.each {|k,v|
        self.send("#{k}=",v) if self.respond_to? k
      }
    end 
    # Get image_magick version of the image
    def image_magick
      if ReportBuilder.has_rmagick?
        _image_magick if respond_to? :_image_magick
        
      else
        raise "Requires RMagick"
      end
    end
    # Based on http://rubyquiz.com/quiz50.html
    def report_building_text(builder)
      if ReportBuilder.has_rmagick?
        # get image_magick version of image
        img = image_magick
        # Resize too-large images. The resulting image is going to be
        # about twice the size of the input, so if the original image is too
        # large we need to make it smaller so the ASCII version won't be too
        # big. The `change_geometry' method computes new dimensions for an
        # image based on the geometry argument. The '320x320>' argument says
        # "If the image is too big to fit in a 320x320 square, compute the
        # dimensions of an image that will fit, but retain the original aspect
        # ratio. If the image is already smaller than 320x320, keep the same
        # dimensions."
        img.change_geometry('320x320>') do |cols, rows|
          img.resize!(cols, rows) if cols != img.columns || rows != img.rows
        end
    
        # Compute the image size in ASCII "pixels" and resize the image to have
        # those dimensions. The resulting image does not have the same aspect
        # ratio as the original, but since our "pixels" are twice as tall as
        # they are wide we'll get our proportions back (roughly) when we render.
        pr = img.rows / font_rows
        pc = img.columns / font_cols
        img.resize!(pc, pr)
    
        img = img.quantize(chars.size, Magick::GRAYColorspace)
        img = img.normalize
    
        out=""
        # Draw the image surrounded by a border. The `view' method is slow but
        # it makes it easy to address individual pixels. In grayscale images,
        # all three RGB channels have the same value so the red channel is as
        # good as any for choosing which character to represent the intensity of
        # this particular pixel.
        border = '+' + ('-' * pc) + '+'
        out += border+"\n"
        img.view(0, 0, pc, pr) do |view|
          pr.times do |i|
            out+= '|'
            pc.times do |j|
              out+= chars[view[i][j].red / (2**16 / chars.size)]
            end
            out+= '|'+"\n"
          end
        end
        out+= border
        builder.preformatted(out)
      else
        raise "Requires RMagick"
      end
    end
    # Generate the code for images on html
    def generate_tag_html(builder)
      attrs=""
      attrs+=" height='#{:height}' " if :height
      attrs+=" width='#{:width}' " if :width
      
      if @type=='svg'
        builder.html("
          <div class='image'>
          <!--[if IE]>
          <embed class='svg'  src='#{@url}' #{attrs}'></embed>
          <![endif]-->
            <object class='svg' data='#{@url}' type='image/svg+xml' #{attrs} ></object>
        </div>")
      else
        builder.html "<img src='#{@url}' alt='#{alt}' #{attrs} />"
      end
    end
    def create_file(directory)
      raise "Must be implemented" 
    end
    def report_building_html(builder)
      create_file(builder.directory)
      generate_tag_html(builder)
    end
    def report_building_pdf(builder)
      require 'tmpdir'
      dir=Dir::mktmpdir
      create_file(dir)
      if @type=='svg'
        if svg_raster
          builder.pdf.image(generate_raster_from_svg(dir))
        else
        # Prawn-svg is not ready for production.
        y=builder.pdf.y
        builder.pdf.svg File.read(@filename), :at=>[0, y-60]
        end
      else
        builder.pdf.image(filename, @options)
      end
    end
    # return filename
    def generate_raster_from_svg(dir)
      out_file="#{dir}/#{@id}.png"
      image_magick.write(out_file)
      out_file
    end
    
    def report_building_rtf(builder)
      require 'tmpdir'
      directory=Dir::mktmpdir
      create_file(directory)
      raise "Not implemented on RTF::Document. Use gem install clbustos-rtf for support" unless builder.rtf.respond_to? :image
      if @type=='svg'
        builder.rtf.image(generate_raster_from_svg(directory))
      else
        builder.rtf.image(filename)
      end
    end
  end
  
  class ImageBlob < Image
    attr_accessor :blob
    def initialize(blob, options=Hash.new)
      super(options)
      @blob=blob      
      if !@type
        if blob[0,40]=~/<svg/
          @type='svg'
        else
          @type='jpg'
        end
      end
    end
    def _image_magick
        that=self
        img=Magick::Image.from_blob(@blob) { 
          if that.type=='svg'
            self.format='SVG'
          end
        }
        img.first
    end
    def create_file(directory)
      FileUtils.mkdir_p directory+"/images"
      @filename=directory+"/images/"+@id+"."+@type
      @url="images/"+@id+"."+@type
      File.open(@filename,"w") do |fp|
        fp.write @blob
      end
      @filename
    end
    
  end
  
  class ImageFilename < Image
    def initialize(filename, options=Hash.new)
      super(options)
      @filename=filename
      File.basename(@filename)=~/\.(.+)$/
      @type=File.basename($1)
    end
    def _image_magick
      Magick::Image.read(@filename).first
    end
    def create_file(directory)
      basedir=directory+"/images"
      out=basedir+"/"+File.basename(@filename)
      @url="images/#{File.basename(@filename)}"
      if(File.exists? @filename)
        FileUtils.mkdir_p basedir
        if (!File.exists? out or (File.mtime(out) < File.mtime(@filename)))
          FileUtils.cp @filename, out
        end
      end
    end
  end
end
