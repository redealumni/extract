defmodule Cortex.Utils.Time do
  @moduledoc """
    Module with utility time functions.
  """
  use Timex

  def last_x_days(days) when is_integer(days) and days > 0 do
    DateTime.utc_now()
    |> Timex.shift(days: -days)
  end

  def x_days_from_now(days) when is_integer(days) and days > 0 do
    DateTime.utc_now()
    |> Timex.shift(days: days)
  end

end
