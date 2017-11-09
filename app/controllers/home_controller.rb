require 'open3'

class HomeController < ApplicationController

def index
end

def click
  @video = params[:video].tempfile.path
  @frame = File.basename(@video, File.extname(@video)) + ".png"
  frame_path = Rails.root.join('public', 'images', @frame)
  system("ffmpeg -i #{@video} -q:v 3 -vframes 1 #{frame_path}")
end

def analyze
  # Get all necessary params
  script = Rails.root.join('lib', 'assets', 'py', 'tracker_web.py')
  path = params[:video]
  sampling_radius = 10
  tolerance = 75
  @units = params[:units]
  length = params[:length].to_i
  x = params[:x].to_i
  y = params[:y].to_i
  ext = File.extname(path)

  # Names for files to be created
  inname = File.basename(path, ext) + ".mov"
  inpath = Rails.root.join('tmp', 'videos', inname)
  outname = File.basename(path, ext) + "-out" + ".mov"
  outpath = Rails.root.join('tmp', 'videos', outname)
  @output = webm = File.basename(path, ext) + "-out" + ".webm"
  webm_path = Rails.root.join('public', 'videos', webm)
  data = File.basename(path, ext) + ".json"
  data_path = Rails.root.join('public', 'json', data)
  @data_download = File.join('json', data)
  
  # Convert to MOV - only one I could get working easily
  @vo1, @ve1, @vs1 = Open3.capture3("ffmpeg -i #{path} -vcodec mpeg4 -acodec aac -strict -2 #{inpath}")
  
  # Run the script
  @po, @pe, @ps = Open3.capture3("python #{script} #{inpath} #{sampling_radius} #{tolerance} #{length} #{x} #{y} #{outpath} #{data_path}")

  # Convert the file to webm
  @vo, @ve, @vs = Open3.capture3("ffmpeg -i #{outpath} #{webm_path}")

  # Get JSON data
  data_str = File.open(data_path, "r").read
  @data = JSON.parse(data_str)
end

end
