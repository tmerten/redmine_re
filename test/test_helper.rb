# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

# This method id needed to be able to call the 
# well-known "logger.debug"-command inside tests.
def logger
  RAILS_DEFAULT_LOGGER
end


# This method extracts all messages from the given 
# error_hash and stores them in an array. This allows
# to analyse the build up error messages more easily
# during tests. 
def extract_error_messages(hash)
  messages = []
  hash.keys.each do |bb|
    hash[bb].keys.each do |datum|
      hash[bb][datum].each do |message|
        messages << message
      end
    end
  end
  messages
end

# As the proper saving of building blocks contains the calling
# of the additional_work_before/after_saving_strategies, this 
# saving is encapsulated in this method. It eases the many saving-
# proceedings needed during tests.
def save_building_block_completely(re_bb, params)
  re_bb.attributes = params[:re_building_block]
  re_bb = ReBuildingBlock.do_additional_work_before_save(re_bb, params)
  assert re_bb.save
  re_bb = ReBuildingBlock.do_additional_work_after_save(re_bb, params)
  re_bb
end
