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
    data={'event.eventTime' => '','event.lastTimestamp'  => '', 'event.firstTimestamp' => ''}
    d = create_driver('mapped_time_key "foobar"')
    d.run(default_tag: 'test') do
      d.feed({'test' => 'config_mapped_time_key'}.merge(data))
    end
    filtered = d.filtered.map {|e| e.last}.first
    puts "result => " + filtered.to_s
    assert_true(filtered['foobar'] != nil)
  end

  def test_config_timestamp_fields()
    data={'event.eventTime' => 'also set','event.lastTimestamp'  => '', 'event.firstTimestamp' => '', 'foo' => 'SET', 'bar' => '', 'baz' => ''}
    d = create_driver('timestamp_fields ["foo","bar","baz"]')
    d.run(default_tag: 'test') do
      d.feed({'test' => 'timestamp_fields'}.merge(data))
    end
    filtered = d.filtered.map {|e| e.last}.first
    puts "result => " + filtered.to_s
    assert_equal(filtered['triggerts'], filtered['foo'])
  end

  def test_notime()
    data={'event.eventTime' => '','event.lastTimestamp'  => '', 'event.firstTimestamp' => ''}
    puts "testcase => " + data.to_s
    d = create_driver
    d.run(default_tag: 'test') do
      d.feed({'test' => 'notime'}.merge(data))
    end
    filtered = d.filtered.map {|e| e.last}.first
    puts "result => " + filtered.to_s
    assert_true(filtered['triggerts'] != nil)
  end

  def test_expected_mappings()
    data=[
      {'expected' => 'event.eventTime', 'event.eventTime' => '2021-09-21T21:39:16.000+0200','event.lastTimestamp'  => '', 'event.firstTimestamp' => ''},
      {'expected' => 'event.eventTime', 'event.eventTime' => '2021-09-21T21:39:16.000+0200','event.lastTimestamp'  => 'notempty', 'event.firstTimestamp' => ''},
      {'expected' => 'event.eventTime', 'event.eventTime' => '2021-09-21T21:39:16.000+0200','event.lastTimestamp'  => 'notempty', 'event.firstTimestamp' => 'alsonotempty'},
      {'expected' => 'event.eventTime', 'event.eventTime' => '2021-09-21T21:39:16.000+0200','event.lastTimestamp'  => '', 'event.firstTimestamp' => 'nonempty'},
      {'expected' => 'event.lastTimestamp', 'event.eventTime' => '','event.lastTimestamp'  => 'exists', 'event.firstTimestamp' => ''},
      {'expected' => 'event.lastTimestamp', 'event.eventTime' => '','event.lastTimestamp'  => 'exists', 'event.firstTimestamp' => 'alsoexists'},
      {'expected' => 'event.firstTimestamp', 'event.eventTime' => '','event.lastTimestamp'  => '', 'event.firstTimestamp' => 'exists'}
    ]
    data.each do |testcase|
      puts "testcase => " + testcase.to_s
      d = create_driver
      d.run(default_tag: 'test') do
        d.feed({'test' => 'expected_mappings'}.merge(testcase))
      end
      filtered = d.filtered.map {|e| e.last}.first
      puts "result => " + filtered.to_s
      assert_equal(filtered['triggerts'], filtered[filtered['expected']])
    end
  end

end
