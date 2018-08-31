defmodule Parsers.IntParserTest do
  use ExUnit.Case
  alias Parsers.IntParser

  test "try parse string" do
    input = %{}
    response = IntParser.parse(input, "test", %{"test" => "asd"})

    assert response == {:error, ["invalid_test"], input}
  end

  test "parse integer" do
    input = %{}
    response = IntParser.parse(input, "test", %{"test" => "1"})

    assert response == {:ok, [], %{test: 1}}
  end

  test "parse integer with atom" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: "1"})

    assert response == {:ok, [], %{test: 1}}
  end

  test "parse integer with default value" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: nil}, default: 1)

    assert response == {:ok, [], %{test: 1}}
  end

  test "parse integer with required" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: nil}, required: true)

    assert response == {:error, ["test_not_provided"], input}
  end

  test "parse integer with max and value < max" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: 1}, max: 100)

    assert response == {:ok, [], %{test: 1}}
  end

  test "parse integer with max and value > max" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: 101}, max: 100)

    assert response == {:error, ["invalid_test"], input}
  end

  test "parse integer with min and value < min" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: 1}, min: 100)

    assert response == {:error, ["invalid_test"], input}
  end

  test "parse integer with min and value > min" do
    input = %{}
    response = IntParser.parse(input, :test, %{test: 101}, min: 100)

    assert response == {:ok, [], %{test: 101}}
  end

end
