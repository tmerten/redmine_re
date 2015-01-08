class Realization < ActiveRecord::Base
end
class ReRealization < ActiveRecord::Base
end

class DeleteRealizationAndCreateReRealization < ActiveRecord::Migration
  def self.up
    create_table :re_realizations do |t|
      t.column :issue_id, :integer
      t.column :re_artifact_properties_id, :integer
    end

    if table_exists?(:realizations)
      Realization.all.each do |p|
        new_realization = ReRealization.new
        new_realization.issue_id = p.issue_id
        new_realization.re_artifact_properties_id = p.re_artifact_properties_id
        new_realization.save
      end
      drop_table :realizations
    end
    
  end

  def self.down
      ReRealization.all.each do |p|
        new_realization = Realization.new
        new_realization.issue_id = p.issue_id
        new_realization.re_artifact_properties_id = p.re_artifact_properties_id
        new_realization.save
      end
    drop_table :re_realizations
  end
end