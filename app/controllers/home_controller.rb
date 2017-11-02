require 'open3'

class HomeController < ApplicationController

def index
end

def upload
  # Get all necessary params
  script = Rails.root.join('lib', 'assets', 'tracker_web.py')
  path = params[:file].tempfile.path
  sampling_radius = 10
  tolerance = 75
  units = 1
  x = 552
  y = 459
  ext = File.extname(path)

  # Names for files to be created
  outname = File.basename(path, ext) + "-out" + ext
  outpath = Rails.root.join('public', 'videos', outname)
  @video = webm = File.basename(path, ext) + "-out" + ".webm"
  webm_path = Rails.root.join('public', 'videos', webm)
  
  # Run the script
  @po, @pe, @ps = Open3.capture3("python #{script} #{path} #{sampling_radius} #{tolerance} #{units} #{x} #{y} #{outpath}")

  # Convert the file to webm
  @vo, @ve, @vs = Open3.capture3("ffmpeg -i #{outpath} #{webm_path}")
end

end
