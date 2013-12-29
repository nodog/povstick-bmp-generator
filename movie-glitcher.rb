# 
# programming
# nodog
# 2013-12-23
#
# movie-glitcher.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.

# coding: binary

require "./bmp_writer.rb"
 
def flip(array_2d, i_beg, i_end, j_beg, j_end)
  i_beg.upto(i_end) do |i|
    array_2d[i][j_beg..j_end] = array_2d[i][j_beg..j_end].reverse
  end
  array_2d
end

def flop(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = Array.new(array_2d)
  j_beg.upto(j_end) do |j|
    i_beg.upto(i_end) do |i|
      array_2d[i][j] = temp_array[i_end - (i - i_beg)][j]
    end
  end
  array_2d
end

def time_stretch(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = Array.new(array_2d)
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
  temp_array = Array.new(array_2d)
  shrink_factor = rand(3) + 2
  j_end.downto(j_beg) do |j|
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
  temp_array = Array.new(array_2d)
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
  temp_array = Array.new(array_2d)
  shrink_factor = rand(3) + 2
  j_beg.upto(j_end) do |j|
    i_beg.upto(i_end) do |i|
      temp_array[i][j] = array_2d[i_beg + ((i - i_beg) * shrink_factor) % (i_end - i_beg)][j]
    end
  end
  temp_array
end

def time_stutter(array_2d, i_beg, i_end, j_beg, j_end)
  temp_array = Array.new(array_2d)
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
  temp_array = Array.new(array_2d)
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


MOVIENAME = "glitcher"
NLEDS = 120
NTIME = 2400
GRIDSPREAD = 10
DILATEFACT = 14
FULLREDBRI = 178
FULLWHIBRI = 128


bmp = BMP::Writer.new(NLEDS, NTIME * DILATEFACT)
movie = Array.new(NLEDS) { Array.new(NTIME, "000000") }

# lay down some red double grid stuff to glitch
rand(0..NTIME / 10 - 1).upto(rand(3 * NTIME / 8..NTIME/2 - 1)) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    red_bri = ((j + i) % GRIDSPREAD == 0) || ((j - i) % GRIDSPREAD == 0) ? FULLREDBRI : 0
    whi_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  end
end

# lay down some red double rampy stuff to glitch
rand(0..NTIME / 2 - 1).upto(rand(NTIME / 2..NTIME - 1)) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    red_bri = (((1.0 * j + i) % GRIDSPREAD) + ((1.0 * j - i) % GRIDSPREAD)).floor * (FULLREDBRI / (2 * GRIDSPREAD))
    whi_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  end
end

# lay down some red rampy stuff to glitch
rand(NTIME / 3..3 * NTIME / 4 - 1).upto(rand(3 * NTIME / 4..NTIME - 1)) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    red_bri = (((1.0 * j + i) % GRIDSPREAD)).floor * (FULLREDBRI / GRIDSPREAD)
    whi_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  end
end

# lay down some white rampy stuff to glitch
rand(3 * NTIME / 4..7 * NTIME / 8 - 1).upto(NTIME - 1) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    whi_bri = (((1.0 * j - i) % GRIDSPREAD)).floor * (2 * FULLWHIBRI / (3 * GRIDSPREAD))
    red_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, whi_bri)
  end
end

1.upto(rand(32..64)) do |i|
#1.upto(1) do |i|
  puts i
  i1 = rand(NLEDS - 1)
  i2 = rand(NLEDS - 1)
  ileft, iright = [i1, i2].minmax
  j1 = rand(NTIME - 1)
  j2 = rand(NTIME - 1)
  jleft, jright = [j1, j2].minmax
 
  chance = rand(8)
  if chance == 0 then
    movie = flip(movie, ileft, iright, jleft, jright)
  elsif chance == 1 then
    movie = flop(movie, ileft, iright, jleft, jright)
  elsif chance == 2 then
    movie = time_stretch(movie, ileft, iright, jleft, jright)
  elsif chance == 3 then
    movie = time_stutter(movie, ileft, iright, jleft, jright)
  elsif chance == 4 then
    movie = space_stretch(movie, ileft, iright, jleft, jright)
  elsif chance == 5 then
    movie = space_stutter(movie, ileft, iright, jleft, jright)
  elsif chance == 6 then
    movie = time_shrink(movie, ileft, iright, jleft, jright)
  else
    movie = space_shrink(movie, ileft, iright, jleft, jright)
  end
end

  # 0.upto(NYARNS - 1) do |k|
  #   yarn_phase = (2.0 * STRETCH) * k * Math::PI / NYARNS
  #   yarn_led = (14.9 * Math.cos(rads + yarn_phase) \
  #               + 18.0 * Math.sin(11.0 * (rads + yarn_phase)) \
  #               - 27.0 * Math.cos(3.0 * (rads + yarn_phase)) \
  #               + 60.0).floor
  #   red_bri = (196.0 * (k + 1) / NYARNS).floor
  #   whi_yarn_lim = (NYARNS * (1.0 - WHITEYARNS)).floor
  #   if k >= whi_yarn_lim then
  #     whi_bri = (196.0 * (k - whi_yarn_lim + 1) / (NYARNS - whi_yarn_lim)).floor
  #   else
  #     whi_bri = 0
  #   end
  #   movie[yarn_led][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  # end

0.upto(NLEDS - 1) do |i|
  0.upto((NTIME * DILATEFACT) - 1) do |j|
    bmp[i,j] = movie[i][NTIME - 1 - j / DILATEFACT]
  end
end 

bmp.save_as(MOVIENAME+".bmp")

