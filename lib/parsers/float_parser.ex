defmodule Parsers.FloatParser do
  @moduledoc "Parse input data for real numbers"

  alias Parsers.ValidationError

  @doc """
  Parse input data for float.

  Returns a tuple with `:ok` or `:error`, a list of messages (used only if returns `:error`) and `struct`.

  `struct` is previous struct. Can be map or tuple, anything else do nothing.
  `param_name` is key name. Can be atom or string.
  `params` is map with input data. Need to be a map.
  `restrictions` is keywords with restrictions of input. Can contains:
    * `:default` - will put input data with this value if input data is nil or empty string.
    * `:max` - the max value. Input data need to be equals or upper of this value. Need to be float or integer number.
    * `:min` - the min value. Input data need to be equals or lower of this value. Need to be float or integer number.
    * `:required` - if `params` map needs to have input value with valid float.

  ### Examples
  Just call:
  ```
  iex> Parsers.FloatParser.parse(%{}, :float, %{float: "1.0"})
  {:ok, [], %{float: 1.0}}

  # With integer value
  iex> Parsers.FloatParser.parse(%{}, :float, %{float: "1"})
  {:ok, [], %{float: 1}}

  # With default value
  iex> Parsers.FloatParser.parse(%{other: 123}, :float, %{float: ""}, default: "1.0")
  {:ok, [], %{float: 1.0, other: 123}}

  # If input data is invalid
  iex> Parsers.FloatParser.parse(%{other: 123}, :float, %{float: "asdsa"})
  {:error, ["invalid_float"], %{other: 123}}

  # If input data is required and not provider
  iex> Parsers.FloatParser.parse(%{other: 123}, :float, %{}, required: true)
  {:error, ["float_not_provided"], %{other: 123}}
  ```
  """
  @doc since: "0.1.0"
  @spec parse(Map | Tuple, String | Atom, Map, Keywords | nil) ::
    {:ok, [], struct} | {:error, [String], struct}

  def parse(struct, param_name, params, restrictions \\ [])
  def parse(struct, param_name, params, restrictions) when is_map(struct),
      do: parse({:ok, [], struct}, param_name, params, restrictions)

  def parse(input, param_name, params, restrictions) when is_tuple(input) do
    case Map.get(params, param_name) do
      val when val in [nil, ""] -> bind_if_valid(input, param_name, nil, restrictions)
      val when is_binary(val) -> str_to_float(input, param_name, val, restrictions)
      val -> bind_if_valid(input, param_name, val, restrictions)
    end
  end

  defp str_to_float(input, param_name, val, restrictions) do
    case Float.parse(val) do
      {parsed_number, ""} -> bind_if_valid(input, param_name, parsed_number, restrictions)
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

  defp check_upper_bound(input, param_name, val, %{max: max}) when is_float(val) or is_integer(val) do
    case val <= max do
      true -> input
      _ -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end
  defp check_upper_bound(input, _param_name, _val, _restrictions) do
    input
  end

  defp check_lower_bound(input, param_name, val, %{min: min}) when is_float(val) or is_integer(val) do
    case val >= min do
      true -> input
      _ -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end
  defp check_lower_bound(input, _param_name, _val, _restrictions) do
    input
  end

  defp set_if_no_errors({:ok, msgs, struct}, param_name, val) when (is_float(val) or is_integer(val)) and is_atom(param_name) do
    {:ok, msgs, Map.put(struct, param_name, val) }
  end
  defp set_if_no_errors({:ok, msgs, struct}, param_name, val) when is_float(val) or is_integer(val) do
    {:ok, msgs, Map.put(struct, String.to_atom(param_name), val) }
  end
  defp set_if_no_errors(input, _param_name, _val), do: input

end
