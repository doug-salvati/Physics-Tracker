class HomeController < ApplicationController

def index
end

def upload
	# @video = params[:video]
	redirect_to "/analyze"
end

end
