defmodule Instacamp.DateTimeHelper do
  @moduledoc """
  Helper module for dealing with dat/time formating.
  """

  @spec format_post_date(Date.t() | DateTime.t() | NaiveDateTime.t()) :: String.t()
  def format_post_date(datetime, format \\ "%b %-d, %Y") do
    case Timex.format(datetime, format, :strftime) do
      {:ok, timex_string} ->
        timex_string

      {:error, _error} ->
        ""
    end
  end
end
