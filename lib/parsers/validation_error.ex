defmodule Parsers.ValidationError do
  @moduledoc false
  
  #Contains functions for handling validation errors
  def add({_, messages, page_request}, msg_code) do
    {:error, [msg_code | messages], page_request}
  end
end
