class AddNameAndPositionToSubtasks < ActiveRecord::Migration
  def self.up
    add_column :re_subtasks, "name", :string
    add_column :re_subtasks, "position", :integer
    add_column :re_subtasks, "re_task_id", :integer

    ReSubtask.all.each do |st|
      properties = ReArtifactProperties.find_by_artifact_id_and_artifact_type(st.id, "ReSubtask")
      parent_relation = ReArtifactRelationship.find_by_sink_id_and_relation_type(properties.id, "parentchild")
      parent_task_properties = ReArtifactProperties.find(parent_relation.source_id)
      parent_task = parent_task_properties.artifact

      if parent_task.instance_of?(ReTask)
        say "changing subtask #{st.inspect}, its properties #{properties.inspect} and its parent relation #{parent_relation.inspect}"
        st.position = parent_relation.position
        st.name = properties.name
        st.re_task_id = parent_task.id

        st.valid?
        say "there might be some inconsistencies in your DB since the subtask could not be saved: #{st.errors.inspect}" unless st.save

        ReArtifactRelationship.where(source_id: properties.id).each do |r|
          unless r.relation_type == "parentchild"
            say "moving incoming subtask relation #{r.inspect} to parent task #{parent_task_properties.inspect}"
            r.source_id = parent_task_properties.id
            r.save
          end
        end
        ReArtifactRelationship.where(sink_id: properties.id).each do |r|
          unless r.relation_type == "parentchild"
            say "moving incoming subtask relation #{r.inspect} to parent task #{parent_task_properties.inspect}"
            r.sink_id = parent_task_properties.id
            r.save
          end
        end
      else
        say "unfortunately I found a subtask #{st.inspect} which is not related to a task. destroying it."
        st.destroy
      end
    end

    say "data moved, now destroying the unneeded ReArtifactProperties and parent relations"
    ReSubtask.all.each do |st|
      properties = ReArtifactProperties.find_by_artifact_id_and_artifact_type(st.id, "ReSubtask")
      parent_relation = ReArtifactRelationship.find_by_sink_id_and_relation_type(properties.id, "parentchild")
      parent_relation.destroy
    end
    ReArtifactProperties.where(artifact_type: "ReSubtask").destroy_all

  end

  def self.down
    say ActiveRecord::IrreversibleMigration
  end
end
