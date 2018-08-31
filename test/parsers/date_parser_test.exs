defmodule Parsers.DateParserTest do
  use ExUnit.Case
  alias Parsers.DateParser

  test "try parser number" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "1"})

    assert response == {:error, ["invalid_test"], input}
  end

  test "try parser string" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "asd"})

    assert response == {:error, ["invalid_test"], input}
  end

  test "parser date" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "2018-08-31"})

    assert response == {:ok, [], %{test: ~D[2018-08-31]}}
  end

  test "parser date with atom" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "2018-08-31"})

    assert response == {:ok, [], %{test: ~D[2018-08-31]}}
  end

  test "parser date with required" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => nil}, required: true)

    assert response == {:error, ["test_not_provided"], input}
  end

  test "parser date with default" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => nil}, default: "2018-08-31")

    assert response == {:ok, [], %{test: ~D[2018-08-31]}}
  end

  test "parser date with max" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "2018-08-31"}, max: "2018-08-31")

    assert response == {:ok, [], %{test: ~D[2018-08-31]}}
  end

  test "parser date with max and value > max" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "2018-09-30"}, max: "2018-08-31")

    assert response == {:error, ["invalid_test"], input}
  end

  test "parser date with min" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "2018-08-31"}, min: "2018-08-30")

    assert response == {:ok, [], %{test: ~D[2018-08-31]}}
  end

  test "parser date with min and value < min" do
    input = %{}
    response = DateParser.parse(input, "test", %{"test" => "2018-08-29"}, min: "2018-08-30")

    assert response == {:error, ["invalid_test"], input}
  end

end
