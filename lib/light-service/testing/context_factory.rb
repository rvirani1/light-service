module LightService
  module Testing
    class ContextFactory
      attr_reader :organizer

      def self.make_from(organizer)
        new(organizer)
      end

      def for(action)
        self
      end

      # More than one arguments can be passed to the
      # Organizer's #call method
      def with(*args, &block)
        catch(:return_ctx_from_execution) do
          @organizer.call(*args, &block)
        end
      end

      def initialize(organizer)
        @organizer = organizer
      end
    end
  end
end
