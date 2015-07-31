require 'json'
require_relative "../../base"
require_relative "../../rake/loggers"
require_relative "../../event"
require_relative "../../event/store"

class CalData
  class Gcal
    class Refine

      extend Rake::Loggers

      def initialize(opts)
        from = opts[:from]
        to   = opts[:to]
        raise "Invalid input (#{from})" unless from.split('.').last == "json"
        raise "Invalid output (#{to})"  unless to.split('.').last == "yaml"
        @from = from
        @to   = to
      end

      def execute
        Event::Store.new(@to).destroy_all.create(events)
        log "Converted GCAL records written to #{@to}"
      end

      private

      def json_events
        return [] unless File.exist?(@from)
        JSON.parse(File.read(@from))
      end

      def events
        json_events.map do |hsh|
          hsh_start = hsh["start"]
          start = hsh_start["date"] || hsh_start["dateTime"].split('T').first
          opts  = {
            gcal_id:  hsh["id"],
            location: hsh["location"],
            title:    hsh["summary"],
            start:    start
          }
          Event.new(opts)
        end
      end
    end
  end
end
