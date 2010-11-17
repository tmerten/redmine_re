class ReArtifactPropertiesObserver < ActiveRecord::Observer
  #observe :re_artifact_properties
  @@save_count = 0  # zaehlt anzahl der save's

   # Durch unerkl�rende Weise wird der callback 2 mal aufgerufen bei ein Speichervorgang(bsp: @re_subtask.save)
   ## Debug Ausschnitt beim editieren von einem Subtask:
      #1############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after update#
      #2############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after save#
      #3############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after update#
      #4############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after save#
   ## Debug Ausschnitt beim erstellen von einem Subtask nur 1.Zeile wird anders:
      #1############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after create#
   #=> Nach langem debuggen habe ich mich zu der dirty l�sung entschieden immer beim 2. Save den Vorgan auszufuehren
   #=> Also immer wenn die Anzahl der save's eine gerade zahl ist
   def after_save(re_artifact)
     # TEMPORAER AUSSTELLUNG DER VERSIONIERUNG, DA ES SONST PROBLEME BEIM EDIT GIBT!!!
     #-----nur da weil ReGoal noch keine versionierung hat und sonst fehler bei erstellung oder edit
     return #if re_artifact.artifact.class.to_s == "ReGoal"
     #----------

     # Wenn ein ReArtifact verschoben wird also sich der parent �ndert
     # Hier wird nur einmal after save aufgerufen daher save_count nicht von interesse
     if( re_artifact.state == State::DROPPING )
        #re_artifact_properties.create_new_version             #TODO : vorher neue version erstellen muss man noch �berlegen
        re_artifact.update_extra_version_columns
        re_artifact.versioning_parent
        re_artifact.state == State::IDLE
     end
     
      Rails.logger.debug("###### after save observer###{Time.now.to_s}#Save_count:#{@@save_count}#1 ReArtifact:" + re_artifact.inspect)
     @@save_count += 1
     isEven = @@save_count % 2 == 0

     if isEven #wenn gerade
       re_artifact.update_extra_version_columns unless re_artifact.state == State::REVERTING
       re_artifact.versioning_parent
     end
   end

    def before_revert(re_artifact)
      re_artifact.state = State::REVERTING
    end

    def after_revert(re_artifact)
       re_artifact.revert
    end
end
