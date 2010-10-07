class ReArtifactObserver < ActiveRecord::Observer
  #observe :re_artifact
  @@save_count = 0  # zaehlt anzahl der save's

   # Durch unerklärende Weise wird der callback 2 mal aufgerufen bei ein Speichervorgang(bsp: @re_subtask.save)
   ## Debug Ausschnitt beim editieren von einem Subtask:
      #1############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after update#
      #2############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after save#
      #3############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after update#
      #4############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after save#
   ## Debug Ausschnitt beim erstellen von einem Subtask nur 1.Zeile wird anders:
      #1############### Thu Sep 09 21:54:18 +0200 2010 ## ReArtifactObserve, Event: ReArtifact after create#
   #=> Nach langem debuggen habe ich mich zu der dirty lösung entschieden immer beim 2. Save den Vorgan auszufuehren
   #=> Also immer wenn die Anzahl der save's eine gerade zahl ist
   def after_save(re_artifact)
     # TEMPORAER AUSSTELLUNG DER VERSIONIERUNG, DA ES SONST PROBLEME BEIM EDIT GIBT!!!
     #-----nur da weil ReGoal noch keine versionierung hat und sonst fehler bei erstellung oder edit
     return #if re_artifact.artifact.class.to_s == "ReGoal"
     #----------

     @@save_count += 1
     isEven = @@save_count % 2 == 0

     if isEven #wenn gerade        #TODO nach revert to von re_artifact attributen realisieren
       re_artifact.update_extra_version_columns unless re_artifact.isReverting
       re_artifact.versioning_parent
     end
   end

    def before_revert(re_artifact)
      re_artifact.isReverting = true
    end

    def after_revert(re_artifact)
       re_artifact.revert
    end
end
