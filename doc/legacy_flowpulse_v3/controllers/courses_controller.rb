class CoursesController < ApplicationController
  before_action :set_root

  def index
    @courses = @root.children.ordered
  end

  def show
    @course = @root.children.find_by!(slug: params[:id])
    @lessons = @course.posts.status_published.ordered
  end

  private
  def set_root
    @root = Taxbranch.find_by!(slug: "corsi")
  end
end
