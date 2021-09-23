require 'helper'

class TestKubEventsTimestampFilter < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf='')
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::KubEventsTimestampFilter).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) do
      create_driver(%[mapped_time_key ""])
    end
    assert_nothing_raised do
      create_driver(%[mapped_time_key "anyvalidstring"])
    end
    assert_raise(Fluent::ConfigError) do
      create_driver(%[timestamp_fields ["foo","bar"]])
    end
    assert_nothing_raised do
      create_driver(%[timestamp_fields ["foo","bar","baz"]])
    end
  end

  def test_config_mapped_time_key()
    data={'event.eventTime' => nil, 'event.lastTimestamp'  => nil, 'event.firstTimestamp' => nil}
    d = create_driver('mapped_time_key "foobar"')
    d.run(default_tag: 'test') do
      d.feed({'test' => 'config_mapped_time_key'}.merge(data))
    end
    filtered = d.filtered.map {|e| e.last}.first
    puts "result => " + filtered.to_s
    assert_false(filtered['foobar'].to_s.empty?)
  end

  def test_config_timestamp_fields()
    data={'event.eventTime' => 'also set','event.lastTimestamp'  => nil, 'event.firstTimestamp' => nil, 'foo' => 'SET', 'bar' => nil, 'baz' => nil}
    d = create_driver('timestamp_fields ["foo","bar","baz"]')
    d.run(default_tag: 'test') do
      d.feed({'test' => 'timestamp_fields'}.merge(data))
    end
    filtered = d.filtered.map {|e| e.last}.first
    puts "result => " + filtered.to_s
    assert_equal(filtered['triggerts'], filtered['foo'])
  end

  def test_notime()
    # data={'event.eventTime' => nil,'event.lastTimestamp'  => nil, 'event.firstTimestamp' => nil}
    data={'event' => {'eventTime' => nil, 'lastTimestamp'  => nil, 'firstTimestamp' => nil}}
    puts "testcase => " + data.to_s
    d = create_driver
    d.run(default_tag: 'test') do
      d.feed({'test' => 'notime'}.merge(data))
    end
    filtered = d.filtered.map {|e| e.last}.first
    puts "result => " + filtered.to_s
    assert_false(filtered['triggerts'].to_s.empty?)
  end

  def test_expected_mappings()
    data=[
      {'expected' => 'event.eventTime', 'event'=> {'eventTime' => '2021-09-21T21:39:16.000+0200','lastTimestamp'  => nil, 'firstTimestamp' => nil}},
      {'expected' => 'event.eventTime', 'event'=> {'eventTime' => '2021-09-21T21:39:16.000+0200','lastTimestamp'  => 'notempty', 'firstTimestamp' => nil}},
      {'expected' => 'event.eventTime', 'event'=> {'eventTime' => '2021-09-21T21:39:16.000+0200','lastTimestamp'  => 'notempty', 'firstTimestamp' => 'alsonotempty'}},
      {'expected' => 'event.eventTime', 'event'=> {'eventTime' => '2021-09-21T21:39:16.000+0200','lastTimestamp'  => nil, 'firstTimestamp' => 'nonempty'}},
      {'expected' => 'event.lastTimestamp', 'event'=> {'eventTime' => nil,'lastTimestamp'  => 'exists', 'firstTimestamp' => nil}},
      {'expected' => 'event.lastTimestamp', 'event'=> {'eventTime' => nil,'lastTimestamp'  => 'exists', 'firstTimestamp' => 'alsoexists'}},
      {'expected' => 'event.firstTimestamp', 'event'=> {'eventTime' => nil,'lastTimestamp'  => nil, 'firstTimestamp' => 'exists'}}
    ]
    data.each do |testcase|
      puts "testcase => " + testcase.to_s
      d = create_driver
      d.run(default_tag: 'test') do
        d.feed({'test' => 'expected_mappings'}.merge(testcase))
      end
      filtered = d.filtered.map {|e| e.last}.first
      puts "result => " + filtered.to_s
      assert_equal(getin(filtered, filtered['expected']), filtered['triggerts'])
    end
  end

end
