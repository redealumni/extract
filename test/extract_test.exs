defmodule ExtractTest do
  use ExUnit.Case
  doctest Extract

  test "greets the world" do
    assert Extract.hello() == :world
  end
end
