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
