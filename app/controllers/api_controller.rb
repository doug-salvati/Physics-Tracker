class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def upload
    msg = { :inpath => "nopath", :frame => "http://weblab.cs.uml.edu/~dsalvati/img/doodle.jpg" }
    render :json => msg
  end
end
