module LightService
  module Organizer
    class WithReducer
      attr_reader :context
      attr_accessor :organizer

      def initialize(monitored_organizer = nil)
        @organizer = monitored_organizer
      end

      def with(data = {})
        @context = LightService::Context.make(data)
        @context.organized_by = organizer
        self
      end

      def reduce(*actions)
        raise "No action(s) were provided" if actions.empty?

        actions.flatten!

        actions.each_with_object(context) do |action, current_context|
          begin
            invoke_action(current_context, action)
          ensure
            # For logging
            yield(current_context, action) if block_given?
          end
        end
      end

      private

      def invoke_action(current_context, action)
        if action.respond_to?(:call)
          action.call(current_context)
        else
          action.execute(current_context)
        end
      end
    end
  end
end
