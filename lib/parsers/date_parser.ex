defmodule Parsers.DateParser do
  @moduledoc "Parse input data for dates"

  alias Parsers.ValidationError

  @doc """
  Parse input data for date.

  `struct` is previous struct. Can be map or tuple, anything else do nothing.
  `param_name` is key name. Can be atom or string.
  `params` is map with input date. Need to be a map.
  `restrictions` is keywords with restrictions of date. Can contains:
    * `:default` - will put input date with this value if input date is nil or empty string.
    * `:max` - the max date. Input date need to be equals or upper of this value.
    * `:min` - the min date. Input date need to be equals or lower of this value.
    * `:required` - if `params` map needs to have date value with valid date.

  ### Examples
  Just call:
      iex> Parsers.DateParser.parse(%{}, :date, %{date: "2018-08-31"})
      {:ok, [], %{test: ~D[2018-08-31]}}

      # With default value
      iex> Parsers.DateParser.parse(%{other: 123}, :date, %{date: ""}, default: "2018-08-31")
      {:ok, [], %{test: ~D[2018-08-31], other: 123}}

      # If input date is invalid
      iex> Parsers.DateParser.parse(%{other: 123}, :date, %{date: "asdsa"})
      {:error, ["invalid_date"], %{other: 123}}

      # If input date is required and not provider
      iex> Parsers.DateParser.parse(%{other: 123}, :date, %{}, required: true)
      {:error, ["date_not_provided"], %{other: 123}}
  """
  def parse(struct, param_name, params, restrictions \\ [])
  def parse(struct, param_name, params, restrictions) when is_map(struct),
      do: parse({:ok, [], struct}, param_name, params, restrictions)

  def parse(input, param_name, params, restrictions) when is_tuple(input) do
    case Map.get(params, param_name) do
      val when val in [nil, ""] -> bind_if_valid(input, param_name, nil, restrictions)
      val when is_binary(val) -> str_to_date(input, param_name, val, restrictions)
      val -> bind_if_valid(input, param_name, val, restrictions)
    end
  end

  defp str_to_date(input, param_name, val, restrictions) do
    case Date.from_iso8601(val) do
      {:ok, date} -> bind_if_valid(input, param_name, date, restrictions)
      {:error, _} -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end

  defp bind_if_valid(input, param_name, nil, [default: val] = restrictions) do
    str_to_date(input, param_name, val, restrictions)
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

  defp check_upper_bound(input, param_name, val, %{max: max}) do
    case Date.from_iso8601(max) do
      {:ok, date} -> check_compare(input, param_name, val, date, [:gt, :eq])
      {:error, _} -> ValidationError.add(input, "invalid_max_value")
    end
  end
  defp check_upper_bound(input, _param_name, _val, _restrictions) do
    input
  end

  defp check_lower_bound(input, param_name, val, %{min: min}) do
    case Date.from_iso8601(min) do
      {:ok, date} -> check_compare(input, param_name, val, date, [:lt, :eq])
      {:error, _} -> ValidationError.add(input, "invalid_min_value")
    end
  end
  defp check_lower_bound(input, _param_name, _val, _restrictions) do
    input
  end

  defp check_compare(input, param_name, val, date, types) do
    case Date.compare(date, val) in types do
      true -> input
      false -> ValidationError.add(input, "invalid_#{param_name}")
    end
  end

  defp set_if_no_errors({:ok, msgs, struct}, param_name, val) when is_atom(param_name) do
    {:ok, msgs, Map.put(struct, param_name, val) }
  end
  defp set_if_no_errors({:ok, msgs, struct}, param_name, val) do
    {:ok, msgs, Map.put(struct, String.to_atom(param_name), val) }
  end
  defp set_if_no_errors(input, _param_name, _val), do: input

end
