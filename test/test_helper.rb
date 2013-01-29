# Default Rails Application Test_Helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class ActiveSupport::TestCase
  # This should speedup testrunning although it does not create data. Instead it uses tranactions for temporarily
  # creating and rolling back test data
  # self.use_transactional_fixtures = true
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
