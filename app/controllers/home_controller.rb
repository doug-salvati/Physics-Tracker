require 'open3'

class HomeController < ApplicationController

def index
end

def click
  @video = params[:video].tempfile.path
end

def analyze
  # Get all necessary params
  script = Rails.root.join('lib', 'assets', 'tracker_web.py')
  path = params[:video]
  sampling_radius = 10
  tolerance = 75
  @units = params[:units]
  length = params[:length].to_i
  x = params[:x].to_i
  y = params[:y].to_i
  ext = File.extname(path)

  # Names for files to be created
  outname = File.basename(path, ext) + "-out" + ext
  outpath = Rails.root.join('public', 'videos', outname)
  @output = webm = File.basename(path, ext) + "-out" + ".webm"
  webm_path = Rails.root.join('public', 'videos', webm)
  
  # Run the script
  @po, @pe, @ps = Open3.capture3("python #{script} #{path} #{sampling_radius} #{tolerance} #{length} #{x} #{y} #{outpath}")

  # Convert the file to webm
  @vo, @ve, @vs = Open3.capture3("ffmpeg -i #{outpath} #{webm_path}")
end

end
