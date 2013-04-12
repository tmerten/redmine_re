class RatingsController < ApplicationController
  unloadable

  def create
    @rap = ReArtifactProperties.find_by_id(params[:re_artifact_properties_id])
    @rating = Rating.new(params[:rating])
    @rating.re_artifact_properties_id = @rap.id
    @rating.user_id = User.current.id
    if @rating.save
      respond_to do |format|
        format.html { redirect_to re_artifact_properties_path(@rap), :notice => "Your rating has been saved" }
        format.js
      end
    end
  end

  def update
    @rap = ReArtifactProperties.find_by_id(params[:re_artifact_properties_id])
    @rating = User.current.ratings.find_by_re_artifact_properties_id(@rap.id)
    if @rating.update_attributes(params[:rating])
      respond_to do |format|
        format.html { redirect_to re_artifact_properties_path(@rap), :notice => "Your rating has been updated" }
        format.js
      end
    end
  end
end
