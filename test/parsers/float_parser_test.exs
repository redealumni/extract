defmodule Parsers.FloatParserTest do
  use ExUnit.Case
  alias Parsers.FloatParser

  test "try parse string" do
    input = %{}
    response = FloatParser.parse(input, "test", %{"test" => "asd"})

    assert response == {:error, ["invalid_test"], input}
  end

  test "parse integer" do
    input = %{}
    response = FloatParser.parse(input, "test", %{"test" => "1"})

    assert response == {:ok, [], %{test: 1.0}}
  end

  test "parse float" do
    input = %{}
    response = FloatParser.parse(input, "test", %{"test" => "1.0"})

    assert response == {:ok, [], %{test: 1.0}}
  end

  test "parse float with atom" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: "1.0"})

    assert response == {:ok, [], %{test: 1.0}}
  end

  test "parse float with default value" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: nil}, default: 1.0)

    assert response == {:ok, [], %{test: 1.0}}
  end

  test "parse float with required" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: nil}, required: true)

    assert response == {:error, ["test_not_provided"], input}
  end

  test "parse float with max and value < max" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: 1.0}, max: 100)

    assert response == {:ok, [], %{test: 1.0}}
  end

  test "parse float with max and value > max" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: 101.0}, max: 100)

    assert response == {:error, ["invalid_test"], input}
  end

  test "parse float with min and value < min" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: 1.0}, min: 100)

    assert response == {:error, ["invalid_test"], input}
  end

  test "parse float with min and value > min" do
    input = %{}
    response = FloatParser.parse(input, :test, %{test: 101.0}, min: 100)

    assert response == {:ok, [], %{test: 101.0}}
  end

end
