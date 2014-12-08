# 
# programming
# nodog
# 2014-12-07
#
# movie-fireworks.rb
# is a generater of a 1D movie (a 2D bmp file) for a 120x1 RGB LED array.
#
# I'm going to try to simulate fireworks on the array.

# coding: binary

require "./bmp_writer.rb"
 
MOVIE_NAME = "frwrks"
N_LEDS = 120
N_TIME = 5000
DILATE_FACT = 3

N_POPS = 32
MIN_POP_PARTICLES = 2
MAX_POP_PARTICLES = 8
MIN_POP_HEIGHT = 10
MAX_POP_HEIGHT = 90
MAX_POP_VEL = 1.0
MAX_BRIGHTNESS = 254
END_TIME_BUFFER = 200
BRIGHTNESS_DECAY = 0.7 
GRAVITY = -0.007

bmp = BMP::Writer.new(N_LEDS, N_TIME * DILATE_FACT)
movie = Array.new(N_LEDS) { Array.new(N_TIME, "000000") }

# in random places on the black canvas draw "pops"
#
# on a pop, a bunch of particles should be generated which have varying positive and negative velocities
#
# afterwards each particle should succumb to the acceleation of gravity just a bit
#  and should fade out
#
# keep track of all particles which have not faded completely

class Particle
  attr_accessor :x, :vel, :brightness
  def initialize( x, vel, brightness)
    @x = x
    @vel = vel
    @brightness = brightness
  end
end

0.upto(N_POPS) do |i|
  pop_start_time = rand(N_TIME - END_TIME_BUFFER)
  pop_start_x = rand(MIN_POP_HEIGHT..MAX_POP_HEIGHT)
  movie[pop_start_x][pop_start_time] = sprintf("%02x%02x%02x", MAX_BRIGHTNESS, MAX_BRIGHTNESS, MAX_BRIGHTNESS)
  color = rand(3)
  n_particles = rand(MIN_POP_PARTICLES..MAX_POP_PARTICLES)
  particles = Array.new(n_particles)
  0.upto(n_particles) do |p|
    vel = rand(-MAX_POP_VEL..MAX_POP_VEL)
    particles[p] = Particle.new(pop_start_x, vel, MAX_BRIGHTNESS)
  end
  current_time = pop_start_time
  until particles[0].brightness < 0 do
    puts "before particle[0].brightness = #{particles[0].brightness}"
    particles.each do |p|
      if p.x >= 0 && p.x < 120
        puts "p.x = #{p.x}  current_time = #{current_time}  p.brightness = #{p.brightness}"
        # the colors here are not obvious, but it's white = 2 (b+g+r), red = 0(r), and green = 1 (g)
        movie[p.x.floor][current_time] = sprintf("%02x%02x%02x", 
                                                 color == 2 ? p.brightness : 0, 
                                                 color > 0 ? p.brightness : 0, 
                                                 color != 1 ? p.brightness : 0)
      end
      p.vel += GRAVITY
      p.x += p.vel
      p.brightness -= BRIGHTNESS_DECAY
    end
    puts "after particle[0].brightness = #{particles[0].brightness}"
    current_time += 1
    puts "current_time = #{current_time}"
  end
end

0.upto(N_LEDS - 1) do |i|
  0.upto((N_TIME * DILATE_FACT) - 1) do |j|
    bmp[i,j] = movie[i][N_TIME - 1 - j / DILATE_FACT]
  end
end 

bmp.save_as("movies/"+MOVIE_NAME+".bmp")
