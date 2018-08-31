defmodule Parsers.DateParser do
  @moduledoc "Parse input data for dates"

  alias Parsers.ValidationError

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