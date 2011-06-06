class ReScenarioController < RedmineReController
  unloadable
  menu_item :re

  # The new and edit functions will be called via the RedmineReController.
  # Both methods are pretty much equal for every artifact type (goal, scenario
  # etc. ).
  #
  # If your artifact type needs special treatment uncommenct the following
  # hook method(s).
  # You find an example of how to use these hooks in the ReTaskController
  
  #def new_hook(params)
  #end

  #def edit_hook_after_artifact_initialized(params)
  #end
  
  #def edit_hook_validate_before_save(params, artifact_valid)
    # must return true, if the validation passed or false if invalid 
    # you should also attach your errors to the @artifact variable

  #  return true
  #end
  
  #def edit_hook_valid_artifact_after_save(params)
  #end
  
  #def edit_hook_invalid_artifact_cleanup(params)
  #end

end