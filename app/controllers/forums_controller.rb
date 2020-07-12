class ForumsController < ApplicationController
  load_and_authorize_resource :forum_group
  load_and_authorize_resource :forum, :through => :forum_group, :shallow => true

  def create
    if @forum.save
      flash[:notice] = "Forum was successfully created."
      redirect_to forums_url
    else
      render :action => 'new'
    end
  end

  def update
    if @forum.update_attributes(forum_params)
      flash[:notice] = "Forum was updated successfully."
      redirect_to forum_url(@forum)
    end
  end

  def destroy
    if @forum.destroy
      flash[:notice] = "Forum was deleted."
      redirect_to forums_url
    end
  end

  def forum_params
    params.require(:forum).permit(:title, :description, :state, :position, :forum_group_id)
  end
end