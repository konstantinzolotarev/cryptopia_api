defmodule CryptopiaApi do
  @moduledoc false

  use HTTPoison.Base

  @host "https://www.cryptopia.co.nz/api/"
  @timeout Application.get_env(:cryptopia_api, :request_timeout, 8000)

  def host, do: @host
  def process_url(url), do: @host <> url

  defp process_request_options([]), do: [timeout: @timeout]
  defp process_request_options([timeout: _t] = opts), do: opts
  defp process_request_options(opts), do: Keyword.merge(opts, [timeout: @timeout])

  defp process_request_body(req) when is_binary(req), do: req
  defp process_request_body(req), do: Poison.encode!(req)

  defp process_response_body(""), do: ""
  defp process_response_body(body) do

    # Cryptopia for some reason send [zero-width whitespace](http://www.fileformat.info/info/unicode/char/200B/index.htm)
    # as a first char in private api. we have to replace it
    # otherwise Poison.decode! will raise an exception
    body
    |> String.replace_prefix(<<0xfeff::utf8>>, "")
    |> Poison.decode!(keys: :atoms)
  end

  def get_body(url), do: get(url) |> fetch_body() |> pick_data()
  def get_body(url, pid), do: get(url, %{}, stream_to: pid)

  def post_body(url, params, headers) do
    post(url, params, headers)
    |> fetch_body()
    |> pick_data()
  end

  defp fetch_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, body}
  defp fetch_body({:ok, %HTTPoison.Response{status_code: 201, body: body}}), do: {:ok, body}
  # Handle not auth for user. API would not return anything in body
  defp fetch_body({:ok, %HTTPoison.Response{status_code: 401}}), do: {:error, "Wrong authorisation !"}
  defp fetch_body({:ok, %HTTPoison.Response{body: body}}), do: {:error, body}
  defp fetch_body({:error, err}), do: {:error, err}
  defp fetch_body(_), do: {:error, "Something went wrong"}

  defp pick_data({:ok, %{Success: true, Data: data}}), do: {:ok, data}
  defp pick_data({:ok, %{Success: false, Error: error}}), do: {:error, error}
  defp pick_data(resp), do: resp
end
