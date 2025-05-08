module MCP
  module Tools
    class Dice
      def initialize
        # 将来的に必要になる可能性のある初期化処理をここに書く
      end

      def tools
        [roll_dice]
      end

      private

      def roll_dice
        {
          name: 'roll_dice',
          description: 'Roll a dice with the specified number of sides',
          input_schema: {
            type: 'object',
            properties: {
              sides: {
                type: 'integer',
                description: 'Number of sides on the dice',
                default: 6
              }
            },
            required: ['sides']
          },
          handler: proc do |args|
            sides = args[:sides] || 6
            rand(1..sides)
          end
        }
      end
    end
  end
end
