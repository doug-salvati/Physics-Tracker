require 'open3'

class HomeController < ApplicationController

def index
end

def click
  @video = params[:video].tempfile.path
  @frame = File.basename(@video, File.extname(@video)) + ".png"
  frame_path = Rails.root.join('public', 'images', @frame)
  @o, @e, @s = Open3.capture3("ffmpeg -i #{@video} -q:v 3 -vframes 1 #{frame_path}")
  logger.info(@o)
  logger.info(@e)
  logger.info(@s)
  if @s.exitstatus != 0
    redirect_to(root_path, {:flash => {:error => "Your file is not in a supported format.  Try:<ul><li>Make sure you are using a VIDEO file</li><li>Convert to a different format on the web</li></ul>"}})
  end
end

def analyze
  @error = 'none'

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
  if @vs1.exitstatus != 0
        redirect_to(root_path, {:flash => {:error => "Failed to convert video for processing. Try:<ul><li>Make sure you are using a proper video file</li><li>Convert to a different format</li></ul>"}})
  end

  # Run Python script!
  loop do
    @po, @pe, @ps = Open3.capture3("python #{script} #{inpath} #{sampling_radius} #{tolerance} #{length} #{x} #{y} #{outpath} #{data_path}")
    if @ps.exitstatus != 0
      tolerance += 5
      if tolerance > 100
        redirect_to(root_path, {:flash => {:error => "Failed during tracking with the following issues:<br/>" + @po}})
        return
      end
    end
    break if @ps.exitstatus == 0
  end

  # Convert the file to webm
  @vo, @ve, @vs = Open3.capture3("ffmpeg -i #{outpath} #{webm_path}")
  if @vs.exitstatus != 0
    flash[:error] = "Unable to show the result video in the browser at this time.<br/>Sorry about that :/"
  end
  # Get JSON data
  
  data_str = File.open(data_path, "r").read
  @data = JSON.parse(data_str)
end

end
