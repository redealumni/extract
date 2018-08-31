defmodule Parsers.IntParser do
  @moduledoc "Parse input data for integers"

  alias Parsers.ValidationError

  @doc """
  Parse input data for integer.

  `struct` is previous struct. Can be map or tuple, anything else do nothing.
  `param_name` is key name. Can be atom or string.
  `params` is map with input data. Need to be a map.
  `restrictions` is keywords with restrictions of input. Can contains:
    * `:default` - will put input data with this value if input data is nil or empty string.
    * `:max` - the max integer. Input data need to be equals or upper of this value.
    * `:min` - the min integer. Input data need to be equals or lower of this value.
    * `:required` - if `params` map needs to have input value with valid integer.

  ### Examples
  Just call:
  ```
  iex> Parsers.IntParser.parse(%{}, :integer, %{integer: "1"})
  {:ok, [], %{integer: 1}}

  # With default value
  iex> Parsers.IntParser.parse(%{other: 123}, :integer, %{integer: ""}, default: "1.0")
  {:ok, [], %{integer: 1.0, other: 123}}

  # If input data is invalid
  iex> Parsers.IntParser.parse(%{other: 123}, :integer, %{integer: "asdsa"})
  {:error, ["invalid_integer"], %{other: 123}}

  # If input data is required and not provider
  iex> Parsers.IntParser.parse(%{other: 123}, :integer, %{}, required: true)
  {:error, ["integer_not_provided"], %{other: 123}}
  ```
  """
  def parse(struct, param_name, params, restrictions \\ [])
  def parse(struct, param_name, params, restrictions) when is_map(struct),
      do: parse({:ok, [], struct}, param_name, params, restrictions)

  def parse(input, param_name, params, restrictions) when is_tuple(input) do
    case Map.get(params, param_name) do
      val when val in [nil, ""] -> bind_if_valid(input, param_name, nil, restrictions)
      val when is_binary(val) -> str_to_int(input, param_name, val, restrictions)
      val -> bind_if_valid(input, param_name, val, restrictions)
    end
  end

  defp str_to_int(input, param_name, val, restrictions) do
    case Integer.parse(val) do
      {parsed_int, ""} -> bind_if_valid(input, param_name, parsed_int, restrictions)
      _ -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end

  defp bind_if_valid(input, param_name, nil, [default: val] = restrictions) do
    bind_if_valid(input, param_name, val, restrictions)
  end
  defp bind_if_valid(input, param_name, val, restrictions) do
    input
    |> check_restrictions(param_name, val, Enum.into(restrictions, %{}))
    |> set_if_no_errors(param_name, val)
  end

  defp check_restrictions(input, param_name, val, restrictions) do
    input
    |> check_required(param_name, val, restrictions)
    |> check_lower_bound(param_name, val, restrictions)
    |> check_upper_bound(param_name, val, restrictions)
  end

  defp check_required(input, param_name, nil, %{required: true}) do
    ValidationError.add(input, "#{param_name}_not_provided")
  end
  defp check_required(input, _param_name, _val, _restrictions) do
    input
  end

  defp check_upper_bound(input, param_name, val, %{max: max}) when is_integer(val) do

    case val <= max do
      true -> input
      _ -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end
  defp check_upper_bound(input, _param_name, _val, _restrictions) do
    input
  end

  defp check_lower_bound(input, param_name, val, %{min: min}) when is_integer(val) do
    case val >= min do
      true -> input
      _ -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end
  defp check_lower_bound(input, _param_name, _val, _restrictions) do
    input
  end

  defp set_if_no_errors({:ok, msgs, struct}, param_name, val) when is_integer(val) and is_atom(param_name) do
    {:ok, msgs, Map.put(struct, param_name, val) }
  end
  defp set_if_no_errors({:ok, msgs, struct}, param_name, val) when is_integer(val) do
    {:ok, msgs, Map.put(struct, String.to_atom(param_name), val) }
  end
  defp set_if_no_errors(input, _param_name, _val), do: input


end
