class ReTask < ActiveRecord::Base
  unloadable

  acts_as_re_artifact

  validates_presence_of :re_artifact_properties

  #acts_as_versioned

    def subtask_attributes=(subtask_attributes)
      subtask_attributes.each do |key, value|
          Rails.logger.debug("###################edit re task##### key / value" + key.to_s+ "/"+value.to_s)
          subtask = ReSubtask.find(key) || ReSubtask.new
          subtask.attributes = value
          subtask.save
      end
    end
end
