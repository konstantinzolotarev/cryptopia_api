defmodule CryptopiaApi do
  @moduledoc false

  use HTTPoison.Base

  @host "https://www.cryptopia.co.nz/api/"

  def process_url(url), do: @host <> url

  defp process_request_body(req) when is_binary(req), do: req
  defp process_request_body(req), do: Poison.encode!(req)

  defp process_response_body(""), do: ""
	defp process_response_body(body), do: Poison.decode!(body, keys: :atoms)

  def get_body(url), do: get(url) |> fetch_body() |> pick_data
  def get_body(url, pid), do: get(url, %{}, stream_to: pid)
  
  def post_body(url), do: post(url, %{})

  defp fetch_body({:ok, %HTTPoison.Response{body: body}}), do: {:ok, body}
  defp fetch_body({:error, err}), do: {:error, err}
  defp fetch_body(_), do: {:error, "Something went wrong"}

  defp pick_data({:ok, %{Success: true, Data: data}}), do: {:ok, data}
  defp pick_data(resp), do: resp
end
