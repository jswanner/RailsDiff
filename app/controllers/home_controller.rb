class HomeController < ApplicationController
  def show
    @versions = Version.order(:version)
  end

  def redirect
    redirect_to '/%s/%s/' % [params[:source], params[:target]]
  end
end
