require 'fluent/test'
require 'fluent/test/helpers'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_kube_events_timestamp'

class Test::Unit::TestCase
  include Fluent::Test::Helpers
end
