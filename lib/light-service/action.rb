module LightService
  module Action
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
        action_context = context.is_a?(::LightService::Context) ? context : LightService::Context.make(context)
        return action_context if action_context.stop_processing?

        # Store the action within the context
        action_context.current_action = self

        LightService::Context::ReservedKeysVerifier.new(action_context, self).verify
        LightService::Context::ExpectedKeyVerifier.new(action_context, self).verify

        action_context.define_accessor_methods_for_keys(expected_keys + promised_keys)

        catch(:jump_when_failed) do
          yield(action_context)
        end

        LightService::Context::PromisedKeyVerifier.new(action_context, self).verify
      end
    end
  end
end
