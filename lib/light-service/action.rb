module LightService
  RESERVED_KEYS = %i[message error_code current_action].freeze

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
      define_singleton_method :execute do |params = {}|
        context = LightService::Context.make(params)
        return context if context.stop_processing?

        # Store the action within the context
        context.current_action = self

        verify_reserved_keys!
        verify_expected_keys!(context)

        context.define_accessor_methods_for_keys(all_keys)

        catch(:jump_when_failed) do
          yield(context)
        end

        verify_promised_keys!(context)
        context
      end
    end

    private

    def all_keys
      expected_keys + promised_keys
    end

    def verify_reserved_keys!
      violated_keys = all_keys & RESERVED_KEYS
      return if violated_keys.empty?

      raise(
        LightService::ReservedKeysInContextError.new(
          "promised or expected keys cannot be a reserved key: [#{violated_keys.to_sentence}]")
      )
    end

    def verify_expected_keys!(action_context)
      violated_keys = expected_keys - action_context.keys
      return if violated_keys.empty?

      raise(
        LightService::ExpectedKeysNotInContextError.new(
          "expected keys #{violated_keys.to_sentence} to be in the context during #{self}"
        )
      )
    end

    def verify_promised_keys!(action_context)
      violated_keys = promised_keys - action_context.keys
      return if violated_keys.empty?

      raise(
        LightService::PromisedKeysNotInContextError.new(
          "promised keys #{violated_keys.to_sentence} to be in the context during #{self}"
        )
      )
    end
  end
end
