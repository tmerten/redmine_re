class ReProcessword < ActiveRecord::Base
  unloadable

  INITIAL_COLOR="#808000"
  
  acts_as_re_artifact
  
end
