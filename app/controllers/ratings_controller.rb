class RatingsController < ApplicationController
  unloadable

  def create
    @rap = ReArtifactProperties.find_by_id(params[:re_artifact_properties_id])
    @rating = Rating.find_or_create_by_re_artifact_properties_id(params[:re_artifact_properties_id])
    @rating.value = params[:rating][:value]
    @rating.user_id = User.current.id

    respond_to do |format|
      if @rating.save
        format.html { redirect_to @rap, :notice => 'Your rating has been saved' }
        format.js
      else
        format.html { redirect_to @rap, :notice => 'Could not be rated' }
      end
    end
  end

  def update
    @rap = ReArtifactProperties.find_by_id(params[:re_artifact_properties_id])
    @rating = User.current.ratings.find_by_re_artifact_properties_id(@rap.id)
    if @rating.update_attributes(params[:rating])
      respond_to do |format|
        format.html { redirect_to @rap, :notice => "Your rating has been updated" }
        format.js
      end
    end
  end
end
