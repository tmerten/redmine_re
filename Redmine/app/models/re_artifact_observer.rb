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
     #-----nur da weil ReGoal noch keine versionierung hat und sonst fehler bei erstellung oder edit
     return if re_artifact.artifact.class.to_s == "ReGoal"
     #----------
     @@save_count += 1
     isEven = @@save_count % 2 == 0
                               #TODO nach revert to von re_artifact attributen realisieren
       versioning_parent(re_artifact)
     end
     update_extra_version_columns(re_artifact)
   end
    # Setzt die eigenen zu Versiontabelle hinzugefügten Spalten
    def update_extra_version_columns(re_artifact)
       #aktuellv ersion herausfinden etwas umständlich aber momentan sicher das korrekt version gewählt wird auch wenn man revert macht
       versionNr = re_artifact.artifact.version
       Rails.logger.debug("############ versionnr: " + versionNr.to_s)
       version   = re_artifact.artifact.versions.find_by_version(versionNr)
       Rails.logger.debug("############ version: " + version.inspect)

       version.updated_by        = User.current.id
       version.artifact_name     = re_artifact.name
       version.artifact_priority = re_artifact.priority

       version.save
    end

    def versioning_parent(re_artifact)
       return if re_artifact.parent.nil? #Nur wenn ein parent existiert

       parent = re_artifact.parent.artifact
       parent.save  # Neue version vom parent(ohne veränderung von attributen)

       # gespeicherte Version zwischenspeichern
       savedParentVersion = parent.versions.last

       #--- Version mit zusatzinformation updaten ---
       # Den verursacher(child) zwischenspeichern
       savedParentVersion.versioned_by_artifact_id      = re_artifact.id
       savedParentVersion.versioned_by_artifact_version = re_artifact.artifact.version


       update_extra_version_columns(parent.re_artifact)#TODO testen ob mit changetothis bei subtask funktioniert

       savedParentVersion.save
  end
