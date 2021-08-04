# frozen_string_literal: true

require_relative '../test_helper'
require_relative 'class_attribute'

module Test
  class ClassAttributesTest < Minitest::Test
    class A
      extend Test::ClassAttribute

      define :one, default: 19
    end

    def test_assign_basic
      assert_equal(19, A.one)
    end

    B = Class.new(A) do
      one 17
    end

    def test_assign_inherit
      assert_equal(19, A.one)
      assert_equal(17, B.one)
    end
  end
end
