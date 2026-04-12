class BlogController < ApplicationController
  allow_unauthenticated_access
  layout "brand_public"

  def index
    @posts = BlogPost.all
    @public_nav_links = flowpulse_public_nav_links
  end

  def show
    @post = BlogPost.find_by_slug!(params[:slug])
    @public_nav_links = flowpulse_public_nav_links
  end

  private
    def flowpulse_public_nav_links
      [
        { label: "Home", href: root_path },
        { label: "About", href: about_path },
        { label: "Blog", href: blog_path }
      ]
    end
end
