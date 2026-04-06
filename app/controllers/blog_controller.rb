class BlogController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = BlogPost.all
  end

  def show
    @post = BlogPost.find_by_slug!(params[:slug])
  end
end
