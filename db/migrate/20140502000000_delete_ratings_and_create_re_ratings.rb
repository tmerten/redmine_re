class Rating < ActiveRecord::Base
end
class ReRating < ActiveRecord::Base
end

class DeleteRatingsAndCreateReRatings < ActiveRecord::Migration
  def self.up
    create_table :re_ratings do |t|
      t.integer :user_id
      t.integer :re_artifact_properties_id
      t.integer :value
    end

    if table_exists?(:ratings)
      if column_exists?(:ratings, :re_artifact_properties_id)
        Rating.all.each do |p|
          new_rating = ReRating.new
          new_rating.user_id = p.user_id
          new_rating.re_artifact_properties_id = p.re_artifact_properties_id
          new_rating.value = p.value
          new_rating.save
        end
        drop_table :ratings
      end
    end
  end

  def self.down
    drop_table :re_ratings
  end
end