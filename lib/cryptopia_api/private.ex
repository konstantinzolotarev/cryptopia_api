defmodule CryptopiaApi.Private do 

  import CryptopiaApi

  @moduledoc """
  Private API for [Cryptopia](https://www.cryptopia.co.nz/Forum/Thread/256)
  """

  @api_key Application.get_env(:cryptopia_api, :api_key, "")
  @secret_key Application.get_env(:cryptopia_api, :secret_key, "")

  defp encode_request(data) when not is_binary(data), do: Poison.encode!(data) |> encode_request()
  defp encode_request(data) do 
    :crypto.hash(:md5, data) 
    # |> Base.encode16() 
    # |> String.downcase()
    |> Base.encode64()
  end

  defp nonce(length \\ 12) do 
    :crypto.strong_rand_bytes(length) 
    |> Base.url_encode64() 
    |> binary_part(0, length)
  end
  
  defp hmac(data) do
    {:ok, secret} = Base.decode64(@secret_key)
    :crypto.hmac(:sha256, secret, data)
    # |> Base.encode16()
    # |> String.downcase()
    |> Base.encode64()
  end

  defp generate_amx(method, params) do
    url = URI.encode(host() <> method, &URI.char_unreserved?/1) |> String.downcase()
    encoded_request = encode_request(params)
    nonce = nonce()
    signature = @api_key <> "POST" <> url <> nonce <> encoded_request
    "amx " <> @api_key <> ":" <> hmac(signature) <> ":" <> nonce
  end

  defp headers(method, params) do  
    [
      {"Authorization", generate_amx(method, params)},
      {"Content-Type", "application/json; charset=utf-8"}
    ]
  end

  defp make_request(method), do: make_request(method, "")
  defp make_request(method, params), do: post_body(method, params, headers(method, params))

  def get_balance, do: make_request("GetBalance", %{Currency: ""})
end
