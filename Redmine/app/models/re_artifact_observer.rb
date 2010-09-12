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
     @@save_count += 1
     isEven = @@save_count % 2 == 0
     if isEven #wenn gerade
       versioning_parent(re_artifact)
     end
   end

    def versioning_parent(re_artifact)
       return if re_artifact.parent.nil? #Nur wenn ein parent existiert

       parent = re_artifact.parent.artifact
       parent.save  # Neue version vom parent(ohne veränderung von attributen)

       # gespeicherte Version zwischenspeichern
       savedParentVersion = parent.versions.last

       #--- Version mit zusatzinformation updaten ---
       # Den verursacher(child) zwischenspeichern
       savedParentVersion.versioned_by_artifact_id = re_artifact.id

       savedParentVersion.updated_by = User.current.id
       savedParentVersion.artifact_name = parent.re_artifact.name
       savedParentVersion.artifact_priority = parent.re_artifact.priority
       #---

       savedParentVersion.save
    end
  end
