# 
# programming
# nodog
# 2013-12-23
#
# movie-glitcher.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary

require "./bmp_writer.rb"

puts "---movie-glither running---"
 
MOVIENAME = "glitcher"
NLEDS = 120
NTIME = 2400
#NTIME = 600
GRIDSPREAD = 10
#DILATEFACT = 1
DILATEFACT = 4 
FULLCOL1BRI = [0, 0, 178]
FULLCOL2BRI = [178, 0, 90]
FULLCOL3BRI = [128, 128, 128]
BORDERODDS = 12
MINGLITCHES = 36
MAXGLITCHES = 64

def deep_copy_2d(array_2d)
  Array.new(NLEDS) {|h| Array.new(array_2d[h])}
end

def flip(array_2d, i_beg, i_end, j_beg, j_end)
  i_beg.upto(i_end) do |i|
    array_2d[i][j_beg..j_end] = array_2d[i][j_beg..j_end].reverse
  end
  array_2d
end

def flop(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  j_beg.upto(j_end) do |j|
    i_beg.upto(i_end) do |i|
      array_2d[i][j] = temp_array[i_end - (i - i_beg)][j]
    end
  end
  array_2d
end

def time_stretch(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  stretch_factor = rand(3) + 2
  j_end.downto(j_beg) do |j|
    new_j = j_beg + (j - j_beg) / stretch_factor
    i_beg.upto(i_end) do |i|
      array_2d[i][j] = temp_array[i][new_j]
    end
  end
  array_2d
end

def time_shrink(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  shrink_factor = rand(3) + 2
  j_beg.upto(j_end) do |j|
    i_beg.upto(i_end) do |i|
      j_offset = ((j - j_beg) * shrink_factor) % (j_end - j_beg)
      j_new = j_beg + j_offset 
      #puts " #{j_offset} #{j_new}"
      array_2d[i][j] = temp_array[i][j_new]
    end
  end
  array_2d
end

def space_stretch(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  stretch_factor = rand(3) + 2
  j_beg.upto(j_end) do |j|
    i_end.downto(i_beg) do |i|
      i_new = i_beg + (i - i_beg) / stretch_factor
      array_2d[i][j] = temp_array[i_new][j]
    end
  end
  array_2d
end

def space_shrink(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  shrink_factor = rand(3) + 2
  j_beg.upto(j_end) do |j|
    i_beg.upto(i_end) do |i|
      temp_array[i][j] = array_2d[i_beg + ((i - i_beg) * shrink_factor) % (i_end - i_beg)][j]
    end
  end
  temp_array
end

def time_stutter(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  stut_j = j_beg
  j_end.downto(j_beg) do |j|
    chance = rand(10)
      #puts " chance = #{chance}, stut_j = #{stut_j}"
    if chance == 0 then
      stut_j += 1 
    end
    i_beg.upto(i_end) do |i|
      temp_array[i][j] = array_2d[i][stut_j]
    end
  end
  temp_array
end

def space_stutter(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = deep_copy_2d(array_2d)
  stut_i = i_beg
  i_stuts = Array.new(i_end - i_beg + 1)
  i_beg.upto(i_end) do |i|
    chance = rand(10)
    #puts " chance = #{chance}, stut_i = #{stut_i}"
    if chance == 0 then
      stut_i += 1 
    end
    i_stuts[i - i_beg] = stut_i
  end
  j_beg.upto(j_end) do |j|
    i_end.downto(i_beg) do |i|
      temp_array[i][j] = array_2d[i_stuts[i - i_beg]][j]
    end
  end
  temp_array
end


bmp = BMP::Writer.new(NLEDS, NTIME * DILATEFACT)
movie = Array.new(NLEDS) { Array.new(NTIME, "000000") }

# lay down some color1 double grid stuff to glitch
rand(0..NTIME / 10 - 1).upto(rand(3 * NTIME / 8..NTIME/2 - 1)) do |j|
  0.upto(NLEDS - 1) do |i|
    bri_array = ((j + i) % GRIDSPREAD == 0) || ((j - i) % GRIDSPREAD == 0) ? FULLCOL1BRI : [0, 0, 0]
    movie[i][j] = sprintf("%02x%02x%02x", bri_array[0], bri_array[1], bri_array[2]) 
  end
end

# lay down some color1 double rampy stuff to glitch
rand(0..NTIME / 2 - 1).upto(rand(NTIME / 2..NTIME - 1)) do |j|
  0.upto(NLEDS - 1) do |i|
    bri = (((1.0 * j + i) % GRIDSPREAD) + ((1.0 * j - i) % GRIDSPREAD)) / (2.0 * GRIDSPREAD)
    bri_array = FULLCOL1BRI.collect {|n| (n * bri).floor}
    movie[i][j] = sprintf("%02x%02x%02x", bri_array[0], bri_array[1], bri_array[2]) 
  end
end

# lay down some color3 rampy stuff to glitch
rand(NTIME / 3..3 * NTIME / 4 - 1).upto(rand(3 * NTIME / 4..NTIME - 1)) do |j|
  0.upto(NLEDS - 1) do |i|
    bri = (((1.0 * j + i) % GRIDSPREAD)) / (1.0 * GRIDSPREAD)
    bri_array = FULLCOL3BRI.collect {|n| (n * bri).floor}
    movie[i][j] = sprintf("%02x%02x%02x", bri_array[0], bri_array[1], bri_array[2]) 
  end
end

# lay down some color2 rampy stuff to glitch
rand(3 * NTIME / 4..7 * NTIME / 8 - 1).upto(NTIME - 1) do |j|
  0.upto(NLEDS - 1) do |i|
    bri = (((1.0 * j - i) % GRIDSPREAD)) / (1.0 * GRIDSPREAD)
    bri_array = FULLCOL2BRI.collect {|n| (n * bri).floor}
    movie[i][j] = sprintf("%02x%02x%02x", bri_array[0], bri_array[1], bri_array[2]) 
  end
end

1.upto(rand(MINGLITCHES..MAXGLITCHES)) do |i|
#1.upto(1) do |i|
  puts i
  i1 = rand(BORDERODDS) == 0 ? 0 : rand(NLEDS - 1)
  i2 = rand(BORDERODDS) == 0 ? (NLEDS - 1) : rand(NLEDS - 1)
  ileft, iright = [i1, i2].minmax
  j1 = rand(BORDERODDS) == 0 ? 0 : rand(NTIME - 1)
  j2 = rand(BORDERODDS) == 0 ? (NTIME - 1) : rand(NTIME - 1)
  jleft, jright = [j1, j2].minmax
 
  chance = rand(10)
  #chance = 6
  if chance <= 2 then
    movie = flip(movie, ileft, iright, jleft, jright)
  elsif chance == 3 then
    movie = flop(movie, ileft, iright, jleft, jright)
  elsif chance == 4 then
    movie = time_stretch(movie, ileft, iright, jleft, jright)
  elsif chance == 5 then
    movie = time_stutter(movie, ileft, iright, jleft, jright)
  elsif chance == 6 then
    movie = space_stretch(movie, ileft, iright, jleft, jright)
  elsif chance == 7 then
    movie = space_stutter(movie, ileft, iright, jleft, jright)
  elsif chance == 8 then
    movie = time_shrink(movie, ileft, iright, jleft, jright)
  else
    movie = space_shrink(movie, ileft, iright, jleft, jright)
  end
end

0.upto(NLEDS - 1) do |i|
  0.upto((NTIME * DILATEFACT) - 1) do |j|
    bmp[i,j] = movie[i][NTIME - 1 - j / DILATEFACT]
  end
end 

bmp.save_as(MOVIENAME + ".bmp")

