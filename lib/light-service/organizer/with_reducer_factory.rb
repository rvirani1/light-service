module LightService
  module Organizer
    class WithReducerFactory
      def self.make(monitored_organizer)
        return WithReducer.new(monitored_organizer)
      end
    end
  end
end
