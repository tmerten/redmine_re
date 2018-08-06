class ReRatingsController < ApplicationController
  unloadable

  def create
    @rap = ReArtifactProperties.find_by_id(params[:re_artifact_properties_id])
    @rating = ReRating.find_or_create_by(re_artifact_properties_id: params[:re_artifact_properties_id])
    @rating.value = params[:re_rating][:value]
    @rating.user_id = User.current.id
    @rating.save
	
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
    @rating = User.current.re_ratings.find_by_re_artifact_properties_id(@rap.id)
    if @rating.update_attributes(params[:re_rating])
      respond_to do |format|
        format.html { redirect_to @rap, :notice => "Your rating has been updated" }
        format.js
      end
    end
  end
end
