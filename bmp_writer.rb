# coding: binary
 
class BMP 
  class Writer
    PIXEL_ARRAY_OFFSET = 54
    BITS_PER_PIXEL     = 24
    DIB_HEADER_SIZE    = 40
    PIXELS_PER_METER   = 2835 # 2835 pixels per meter is basically 72dpi
 
    def initialize(width, height)
      @width, @height = width, height
 
      @pixels = Array.new(@height) { Array.new(@width) { "000000" } }
    end
 
    def [](x,y)
      @pixels[y][x]
    end
 
    def []=(x,y,value)
      @pixels[y][x] = value
    end
 
    def save_as(filename)
      File.open(filename, "wb") do |file|
        write_bmp_file_header(file)
        write_dib_header(file)
        write_pixel_array(file)
      end
    end
 
    private
 
    def write_bmp_file_header(file)
      file << ["BM", file_size, 0, 0, PIXEL_ARRAY_OFFSET].pack("A2Vv2V")
    end
 
    def file_size
      PIXEL_ARRAY_OFFSET + pixel_array_size 
    end
 
    def pixel_array_size
      ((BITS_PER_PIXEL*@width)/32.0).ceil*4*@height
    end
   
    # Note: the 'right' pattern to use is actually "Vl<2v2V2l<2V2", but that only works on 1.9.3
    def write_dib_header(file)
      file << [DIB_HEADER_SIZE, @width, @height, 1, BITS_PER_PIXEL,
               0, pixel_array_size, PIXELS_PER_METER, PIXELS_PER_METER, 
               0, 0].pack("V3v2V6")
    end
 
    def write_pixel_array(file)
      @pixels.reverse_each do |row|
        row.each do |color|
          file << pixel_binstring(color)
        end
 
        file << row_padding
      end
    end
 
    def pixel_binstring(rgb_string)
      raise ArgumentError unless rgb_string =~ /\A\h{6}\z/
      [rgb_string].pack("H6")
    end
 
    def row_padding
      "\x0" * (@width % 4)
    end
  end
end
 
NLEDS = 120
BLIPLENGTH = 1
RAMPLENGTH = 255
NT = 1024 + BLIPLENGTH + 2
bmp = BMP::Writer.new(NLEDS,NT)

# need an array the length of NT which switches from black (000000) to red (0000FF) to black to white (FFFFFF) to black

black = Array.new(NT, "000000")
white = Array.new(NT, "FFFFFF")
0.upto(RAMPLENGTH) do |j|
  # red
  black[j] = "0000" + sprintf("%02x", j)
  black[j+RAMPLENGTH+BLIPLENGTH+3] = "0000" + sprintf("%02x", RAMPLENGTH-j)
  # white
  #black[j+NT/2] = sprintf("%02x", j) * 3
  #black[j+RAMPLENGTH+BLIPLENGTH+3+NT/2] =  sprintf("%02x", RAMPLENGTH-j) * 3
  # green 
  black[j+NT/2] = "0000" + sprintf("%02x", j)
  black[j+RAMPLENGTH+BLIPLENGTH+3+NT/2] =  "0000" + sprintf("%02x", RAMPLENGTH-j)
end

0.upto(BLIPLENGTH-1) do |j|
  black[RAMPLENGTH+2+j] = "00FF00"
  black[RAMPLENGTH+2+NT/2+j] = "00FF00"
end


0.upto(NLEDS - 1) do |i|
  #offset = rand(NT)
  #offset = NT - i*23 + (i % 2) * (NT/2)
  offset = NT + ((i * 20 % 1024) - 512).abs 
  0.upto(NT - 1) do |j|
    bmp[i,j] = black[(j + offset) % NT ]
  end
end 

#bmp[0,0] = "ff0000"
#bmp[1,0] = "00ff00"
#bmp[0,1] = "0000ff"
#bmp[1,1] = "ffffff"
 
bmp.save_as("example_generated.bmp")
