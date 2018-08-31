defmodule Cortex.Util.TimeTest do
  use ExUnit.Case
  alias Cortex.Util.Time

  describe "last_x_days" do
    test "days is string" do
      assert_raise UndefinedFunctionError, fn ->
        Time.last_x_days("a")
      end
    end

    test "days is negative number" do
      assert_raise UndefinedFunctionError, fn ->
        Time.last_x_days(-1)
      end
    end
  end

  describe "x_days_from_now" do
    test "days is string" do
      assert_raise UndefinedFunctionError, fn ->
        Time.x_days_from_now("a")
      end
    end

    test "days is negative number" do
      assert_raise UndefinedFunctionError, fn ->
        Time.x_days_from_now(-1)
      end
    end
  end

end
