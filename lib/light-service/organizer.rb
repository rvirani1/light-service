module LightService
  module Organizer
    attr_reader :context

    def with(data = {})
      data[:_aliases] = @aliases if @aliases
      @context = LightService::Context.make(data)
      self
    end

    def reduce(*actions)
      raise "No action(s) were provided" if actions.empty?

      actions.flatten!

      actions.each_with_object(context) do |action, current_context|
        action.execute(current_context)
      end
    end

    def aliases(key_hash)
      @aliases = key_hash
    end
  end
end
