require 'active_support/deprecation'

module LightService
  module Organizer
    def self.extended(base_class)
      base_class.extend ClassMethods
      base_class.extend Macros
    end

    def self.included(base_class)
      warning_msg = "including LightService::Organizer is deprecated. " \
                    "Please use `extend LightService::Organizer` instead"
      ActiveSupport::Deprecation.warn(warning_msg)
      extended(base_class)
    end

    # In case this module is included
    module ClassMethods
      def with(data = {})
        VerifyCallMethodExists.run(self, caller(1..1).first)
        data[:_aliases] = @aliases if @aliases

        WithReducerFactory.make(self).with(data)
      end

      def reduce(*actions)
        with({}).reduce(actions)
      end

      def execute(code_block)
        Execute.run(code_block)
      end

      def log_with(logger)
        @logger = logger
      end

      def logger
        @logger
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
