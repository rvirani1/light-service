module LightService
  module Organizer
    def self.extended(base_class)
      base_class.extend ClassMethods
      base_class.extend Macros
    end

    # In case this module is included
    module ClassMethods
      def with(data = {})
        data[:_aliases] = @aliases if @aliases

        WithReducer.new(self).with(data)
      end

      def reduce(*actions)
        with({}).reduce(actions)
      end

      def execute(code_block)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          code_block.call(ctx)
          ctx
        end
      end

      def add_to_context(**args)
        args.map do |key, value|
          execute(->(ctx) { ctx[key.to_sym] = value })
        end
      end

      def add_aliases(args)
        execute(->(ctx) { ctx.assign_aliases(ctx.aliases.merge(args)) })
      end
    end

    module Macros
      def aliases(key_hash)
        @aliases = key_hash
      end
    end
  end
end
