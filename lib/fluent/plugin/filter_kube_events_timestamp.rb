require 'fluent/plugin/filter'

def decomposite_key(key)
  key.split('.')
end

def getin(hash, key)
  hash.dig(*decomposite_key(key))
end

module Fluent::Plugin
  class KubEventsTimestampFilter < Filter

    Fluent::Plugin.register_filter('kube_events_timestamp', self)

    config_param :mapped_time_key, :string, default: 'triggerts'
    config_param :timestamp_fields, :array, default: ['event.eventTime', 'event.lastTimestamp', 'event.firstTimestamp'], value_type: :string

    def configure(conf)
      super
      require 'date'
      @strftime_format = "%Y-%m-%dT%H:%M:%S.%3N%z".freeze
      raise Fluent::ConfigError, "mapped_time_key can not be empty" if mapped_time_key.to_s.empty?
      raise Fluent::ConfigError, "timestamp_fields must have 3 items" if timestamp_fields.length != 3
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter(tag, time, record)

      vals=@timestamp_fields.map do |field|; getin(record, field); end

      record[@mapped_time_key] = (vals[0].to_s.empty?) ? (vals[1].to_s.empty?) ? vals[2] : vals[1] : vals[0]

      # record[@mapped_time_key] = (getin(record,@timestamp_fields[0]).to_s.empty?) ? (getin(record,@timestamp_fields[1]).to_s.empty?) ? getin(record,@timestamp_fields[2]) : getin(record,@timestamp_fields[1]) : getin(record,@timestamp_fields[0])

      if record[@mapped_time_key].to_s.empty?
        record[@mapped_time_key] = Time.at(time.is_a?(Fluent::EventTime) ? time.to_int : time).strftime(@strftime_format)
      end
      $log.debug("Timestamp added: #{@mapped_time_key}:#{record[@mapped_time_key]}")
  
      record
    end
  end
end

