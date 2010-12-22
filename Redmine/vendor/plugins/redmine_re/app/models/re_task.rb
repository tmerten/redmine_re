class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

   #acts_as_versioned

  def subtask_attributes=(subtask_attributes)
      subtask = nil
      @new_subtasks = { "before" => {}, "after" => {}} # new subtask will be categorized here

      subtask_attributes.each do |id, attributes|
        @is_new = id.to_s.start_with?("new")   # Every new Subtask has id = new_before_20_3948343848
        if(@is_new)
          # Create and save new Subtask
          subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
                                                                                       :created_by => User.current.id,
                                                                                       :updated_by => User.current.id))
          subtask.attributes = attributes
          subtask.re_artifact_properties.parent = self
          @saved = subtask.save

          if @saved
            # Adding current subtask to his category (before or after)
            ## example id when new subtask: new_before_20_1292590912
            #                                new_AddPosition_ClickedSubtask_TimeClicked

            splitted_id = id.to_s.split("_")

            add_position = splitted_id[1] # before / after
            clicked_subtask_artifact_id = splitted_id[2] # Subtask on which the before link was clicked
            time_clicked = splitted_id[3] # 32432433

            # :new_subtasks => { "before" => { "1232432423" => 1 }, "after" => { "3443443" => 2} }
            @new_subtasks[add_position][time_clicked] = {"new_subtask_artifact_id" => subtask.re_artifact_properties.id, "clicked_subtask_artifact_id" => clicked_subtask_artifact_id}
          end
        else # edit existent Subtasks
          subtask = ReSubtask.find(id)
          subtask.attributes = attributes
          subtask.save
        end
    end

    #After saving all new Subtasks set positions
    #at first set the position of every subtask in the before hash
    if @new_subtasks["before"].length > 0
      set_subtasks_positions(@new_subtasks["before"], 0)       #
    end
    #then set the position of every subtask in the after hash
    if @new_subtasks["after"].length > 0
      set_subtasks_positions(@new_subtasks["after"],  1)
    end
  end

  def set_subtasks_positions(subtasks, pos_increment) #subtasks hash, pos_incremente: value the position needs be increment
    #sort after: newest ---> oldest
    old_to_new = subtasks.sort { |a, b| a[0].to_i <=> b[0].to_i }

          old_to_new.each do |array| #["1292607606", {"clicked_subtask_artifact_id"=>"6", "new_subtask_artifact_id"=>94}]

            new_subtask_artifact_id     = array[1]["new_subtask_artifact_id"]
            clicked_subtask_artifact_id = array[1]["clicked_subtask_artifact_id"]

            # get the parent child relation of the clicked subtask in order to get the position of the clicked subtask
            @relation_clicked_subtask = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.re_artifact_properties.id,#subtask.re_artifact_properties.parent.id,
                                                                                      clicked_subtask_artifact_id,
                                                                                      ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                    )
                      # get the parent child relation of the clicked subtask in order to get the position of the clicked subtask
            @relation_new_subtask = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.re_artifact_properties.id,#subtask.re_artifact_properties.parent.id,
                                                                                       new_subtask_artifact_id,
                                                                                      ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                    )
            # insert current new subtask at the current position of the clicked subtask
            @relation_new_subtask.insert_at(@relation_clicked_subtask.position + pos_increment)
         end

  end

end
