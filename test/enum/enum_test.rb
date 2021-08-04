# frozen_string_literal: true

require_relative '../test_helper'
require_relative 'enum'

module Test
  class EnumTest < Minitest::Test
    Pole = Enum.of(:east, :west, :north, :south)

    def test_class_values
      assert_equal(%i[east west north south], Pole.values.to_a)
    end

    def test_instance_values
      pole = Pole.(:north)

      assert_equal(%i[east west north south], pole.values.to_a)
    end

    def test_valid_assign
      pole = Pole.(:north)
      assert_equal(:north, pole.value)

      pole.value = :south
      assert_equal(:south, pole.value)
    end

    def test_invalid_assign
      pole = Pole.(:north)
      assert_raises ArgumentError do
        pole.value = :invalid
      end
    end

    def test_predicators
      pole = Pole.(:north)
      assert(pole.north?)
    end
  end
end
