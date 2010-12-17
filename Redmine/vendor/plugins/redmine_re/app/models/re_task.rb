class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

  #acts_as_versioned


      def subtask_attributes=(subtask_attributes)
      subtask = nil
      @new_subtasks = { "before" => {}, "after" => {}} # new subtask will be categorized here

      subtask_attributes.each do |key, value|
          @is_new = key.to_s.start_with?("new")   # Every new Subtask has id = new_before_20_3948343848
          if(@is_new)
            subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
                                                                                         :created_by => User.current.id,
                                                                                         :updated_by => User.current.id))
            subtask.attributes = value
            subtask.re_artifact_properties.parent = self
            @ok = subtask.save

            #Adding current subtask to his category (before or after)
            #example key when new subtask: new_before_20_1292590912
            #                              new_AddPosition_ClickedSubtask_TimeClicked
            splitted_key = key.to_s.split("_")
            add_position = splitted_key[1]      # before / after
            clicked_subtask_artifact_id = splitted_key[2]   # Subtask on which the before link was clicked
            time_clicked = splitted_key[3]      # 32432433

            # :new_subtasks => { "before" => { "1232432423" => 1 }, "after" => { "3443443" => 2} }
            @new_subtasks[add_position][time_clicked] = {"new_subtask_artifact_id" => subtask.re_artifact_properties.id, "clicked_subtask_artifact_id" => clicked_subtask_artifact_id}

            Rails.logger.debug("############################# suba trr######0 hash new subtasks:  " + @new_subtasks.inspect)

          else
            subtask = ReSubtask.find(key)
            subtask.attributes = value
            subtask.re_artifact_properties.parent = self #not necessary here
            @ok = subtask.save
          end
      end
      #at first set the position of every subtask in the before hash
      if @new_subtasks["before"].length > 0

        #sort before: oldest --> newest   #todo:berichtigen
        before_old_to_new = @new_subtasks["before"].sort { |a, b| a[0].to_i <=> b[0].to_i }

        Rails.logger.debug(">>>>>>>>>>>>>>>> before new to old " + before_old_to_new.inspect)

        before_old_to_new.each do |array|
          new_subtask_artifact_id     = array[1]["new_subtask_artifact_id"]
          clicked_subtask_artifact_id = array[1]["clicked_subtask_artifact_id"]   #["1292607606", ["50", "20" ]] 1 is the re_artifact_properties id of the subtask

          Rails.logger.debug(">>>>>>>>>>>>>>>> before new to old >>>>< new sub / clicked sub " + new_subtask_artifact_id.to_s + " / " + clicked_subtask_artifact_id.to_s)

          # get the parent child relation of the clicked subtask in order to get the position of the clicked subtask
          @relation_clicked_subtask = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.re_artifact_properties.id,#subtask.re_artifact_properties.parent.id,
                                                                                    clicked_subtask_artifact_id,
                                                                                    ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                  )
          Rails.logger.debug(">>>>>>>>>>>>>>>> before new to old >>>>< relation clicked" + @relation_clicked_subtask.inspect)

                    # get the parent child relation of the clicked subtask in order to get the position of the clicked subtask
          @relation_new_subtask = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.re_artifact_properties.id,#subtask.re_artifact_properties.parent.id,
                                                                                     new_subtask_artifact_id,
                                                                                    ReArtifactRelationship::RELATION_TYPES[:parentchild]
                                                                                  )
          Rails.logger.debug(">>>>>>>>>>>>>>>> before new to old >>>>< relation new subtask" + @relation_new_subtask.inspect)

          Rails.logger.debug("\n\n>>>>>>>>>>>>>>>> before new to old >>>>< position clicked subtask  / new sub before insert" + @relation_clicked_subtask.position.to_s + " / " + @relation_new_subtask.position.to_s)

          # insert current new subtask at the current position of the clicked subtask
          @relation_new_subtask.insert_at(@relation_clicked_subtask.position)
          Rails.logger.debug("\n\n>>>>>>>>>>>>>>>> before new to old >>>>< position clicked subtask  / new sub after insert" + @relation_clicked_subtask.position.to_s + " / " + @relation_new_subtask.position.to_s)



        end
      end
      # then set all positions for the after subtasks  #todo: duplicate code
      if @new_subtasks["after"].length > 0

        #sort after: newest ---> oldest
        after_new_to_old  = @new_subtasks["after"].sort { |a, b| b[0].to_i <=> a[0].to_i }

        after_new_to_old.each do |array| #["1292607606", {"clicked_subtask_artifact_id"=>"6", "new_subtask_artifact_id"=>94}]

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
          @relation_new_subtask.insert_at(@relation_clicked_subtask.position + 1)
             
        end

        Rails.logger.debug("##############subb attr #####5555 before sort: " + before_old_to_new.inspect)
        Rails.logger.debug("##############subb attr #####5555 after sort: " + after_new_to_old.inspect)

      end
    end
#    def subtask_attributes=(subtask_attributes)
#      subtask = nil
#      @new_position = nil
#      #@new_subtasks_added_before = {}
#      #@new_subtasks_added_after  = {}
#      subtask_attributes.each do |key, value|
#          @is_new = key.to_s.start_with?("new")
#          if(@is_new) # Every new Subtask has id = new394834384848
#            subtask =  ReSubtask.new(:re_artifact_properties => ReArtifactProperties.new(:project_id => self.project_id,#TODO: getting project_id from task should be changed, otherwise create new task with new subtasks won't work
#                                                                                         :created_by => User.current.id,
#                                                                                         :updated_by => User.current.id))
#
#            @new_position = value.delete(:position)
#            Rails.logger.debug("##### suba ttr#####1    " + @new_position.to_s)
#          else
#            subtask = ReSubtask.find(key)
#          end
#          subtask.attributes = value
#          subtask.re_artifact_properties.parent = self
#          ok = subtask.save
#          Rails.logger.debug("######## sub attr######2 subtask" + subtask.inspect + " ok? : " + ok.to_s)
#          Rails.logger.debug("######## sub attr######3 sub reartifact" + subtask.re_artifact_properties.inspect)
#          Rails.logger.debug("######## sub attr######4 parent " + subtask.re_artifact_properties.parent.inspect)
#
#          #position when new subtask
#          if @is_new
#            @relation = ReArtifactRelationship.find_by_source_id_and_sink_id_and_relation_type( self.re_artifact_properties.id,#subtask.re_artifact_properties.parent.id,
#                                                                                                subtask.re_artifact_properties.id,
#                                                                                                ReArtifactRelationship::RELATION_TYPES[:parentchild]
#                                                                                              )
#             Rails.logger.debug("######## sub attr######5 befoe insert" + @relation.inspect)
#            @relation.insert_at(@new_position)
#            Rails.logger.debug("######## sub attr######6 after insert" + @relation.inspect)
#
#              #TODO: ne position geht noch nicht
#            #@relation.save
#          end
#      end
#    end
end
