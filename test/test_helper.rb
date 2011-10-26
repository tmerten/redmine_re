# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

def logger
  RAILS_DEFAULT_LOGGER
end

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

def save_building_block_completely(re_bb, params)
  re_bb.attributes = params[:re_building_block]
  re_bb = ReBuildingBlock.do_additional_work_before_save(re_bb, params)
  assert re_bb.save
  re_bb = ReBuildingBlock.do_additional_work_after_save(re_bb, params)
  re_bb
end
