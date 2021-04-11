require 'active_support/deprecation'

module LightService
  module Action
    def self.extended(base_class)
      base_class.extend Macros
    end

    module Macros
      def expects(*args)
        expected_keys.concat(args)
      end

      def promises(*args)
        promised_keys.concat(args)
      end

      def expected_keys
        @expected_keys ||= []
      end

      def promised_keys
        @promised_keys ||= []
      end

      def executed
        define_singleton_method :execute do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.stop_processing?

          # Store the action within the context
          action_context.current_action = self

          Context::KeyVerifier.verify_keys(action_context, self) do
            action_context.define_accessor_methods_for_keys(expected_keys + promised_keys)

            catch(:jump_when_failed) do
              yield(action_context)
            end
          end
        end
      end

      private

      def create_action_context(context)
        return context if context.is_a? LightService::Context

        LightService::Context.make(context)
      end
    end
  end
end
