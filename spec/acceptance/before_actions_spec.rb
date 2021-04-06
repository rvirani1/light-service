require 'spec_helper'
require 'test_doubles'

RSpec.describe 'Action before_actions' do
  describe 'works with simple organizers - from outside' do
    it 'can be used to inject code block before each action' do
      TestDoubles::AdditionOrganizer.before_actions =
        lambda do |ctx|
          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsThreeAction
        end

      result = TestDoubles::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(4)
    end
  end

  describe 'can be added to organizers declaratively' do
    module BeforeActions
      class AdditionOrganizer
        extend LightService::Organizer
        before_actions (lambda do |ctx|
                          if ctx.current_action == TestDoubles::AddsOneAction
                            ctx.number -= 2
                          end
                        end),
                       (lambda do |ctx|
                          if ctx.current_action == TestDoubles::AddsThreeAction
                            ctx.number -= 3
                          end
                        end)

        def self.call(number)
          with(:number => number).reduce(actions)
        end

        def self.actions
          [
            TestDoubles::AddsOneAction,
            TestDoubles::AddsTwoAction,
            TestDoubles::AddsThreeAction
          ]
        end
      end
    end

    it 'accepts before_actions hook lambdas from organizer' do
      result = BeforeActions::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(1)
    end
  end
end
