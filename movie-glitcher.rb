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
  temp_array = array_2d
  j_beg.upto(j_end) do |j|
    i_beg.upto(i_end) do |i|
      array_2d[i][j] = temp_array[i_end - (i - i_beg)][j]
    end
  end
  array_2d
end

MOVIENAME = "glitcher"
NLEDS = 120
NTIME = 1200
GRIDSPREAD = 10
DILATEFACT = 12
FULLBRIGHT = 178


bmp = BMP::Writer.new(NLEDS, NTIME * DILATEFACT)
movie = Array.new(NLEDS) { Array.new(NTIME, "000000") }

# lay down some red double rampy stuff to glitch
rand(0..NTIME / 2 - 1).upto(rand(NTIME / 2..NTIME - 1)) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    red_bri = (((1.0 * j + i) % GRIDSPREAD) + ((1.0 * j - i) % GRIDSPREAD)).floor * (FULLBRIGHT / (2 * GRIDSPREAD))
    whi_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  end
end

# lay down some red rampy stuff to glitch
rand(NTIME / 3..3 * NTIME / 4 - 1).upto(rand(3 * NTIME / 4..NTIME - 1)) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    red_bri = (((1.0 * j + i) % GRIDSPREAD)).floor * (FULLBRIGHT / GRIDSPREAD)
    whi_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, red_bri)
  end
end

# lay down some white rampy stuff to glitch
rand(3 * NTIME / 4..7 * NTIME / 8 - 1).upto(rand(7 * NTIME / 8..NTIME - 1)) do |j|
  progress = 1.0 * j / NTIME
  rads = progress * Math::PI * 2.0
  0.upto(NLEDS - 1) do |i|
    whi_bri = (((1.0 * j - i) % GRIDSPREAD)).floor * (2 * FULLBRIGHT / (3 * GRIDSPREAD))
    red_bri = 0
    movie[i][j] = sprintf("%02x%02x%02x", whi_bri, whi_bri, whi_bri)
  end
end

1.upto(rand(32..64)) do |i|
  puts i
  i1 = rand(NLEDS - 1)
  i2 = rand(NLEDS - 1)
  ileft, iright = [i1, i2].minmax
  j1 = rand(NTIME - 1)
  j2 = rand(NTIME - 1)
  jleft, jright = [j1, j2].minmax
 
  if rand(2) == 0 then
    movie = flip(movie, ileft, iright, jleft, jright)
  else
    movie = flop(movie, ileft, iright, jleft, jright)
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

