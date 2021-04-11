module LightService
  class ExpectedKeysNotInContextError < StandardError; end
  class PromisedKeysNotInContextError < StandardError; end
  class ReservedKeysInContextError < StandardError; end
end
