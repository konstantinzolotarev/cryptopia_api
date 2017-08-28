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

  @doc """
  Get list of all currencies on account

  ## Example
  ```elixir
  iex(51)> CryptopiaApi.Private.get_balance
  {:ok,
    [%{Address: nil, Available: 0.0, BaseAddress: nil, CurrencyId: 331,
      HeldForTrades: 0.0, PendingWithdraw: 0.0, Status: "OK", StatusMessage: nil,
      Symbol: "1337", Total: 0.0, Unconfirmed: 0.0},
     ...]}
  ```
  """
  @spec get_balance() :: {:ok, [any]} | {:error, any}
  def get_balance, do: get_balance("")

  @doc """
  Load balance only for given currency id

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Private.get_balance(1)
  {:ok,
    [%{Address: nil, Available: 7.7355e-4, BaseAddress: nil, CurrencyId: 1,
      HeldForTrades: 0.0, PendingWithdraw: 0.0, Status: "OK", StatusMessage: nil,
      Symbol: "BTC", Total: 7.7355e-4, Unconfirmed: 0.0}]}
  ```
  """
  @spec get_balance(number) :: {:ok, [any]} | {:error, any}
  def get_balance(currencyId) when is_number(currencyId), do: make_request("GetBalance", %{CurrencyId: currencyId})

  @doc """
  Load balance only for given currency name or id

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Private.get_balance("BTC")
  {:ok,
    [%{Address: nil, Available: 7.7355e-4, BaseAddress: nil, CurrencyId: 1,
      HeldForTrades: 0.0, PendingWithdraw: 0.0, Status: "OK", StatusMessage: nil,
      Symbol: "BTC", Total: 7.7355e-4, Unconfirmed: 0.0}]}
  ```
  """
  @spec get_balance(String.t) :: {:ok, [any]} | {:error, any}
  def get_balance(currency), do: make_request("GetBalance", %{Currency: currency})

  def get_deposit_address(currencyId) when is_number(currencyId), do: make_request("GetDepositAddress", %{CurrencyId: currencyId})
  def get_deposit_address(currency), do: make_request("GetDepositAddress", %{Currency: currency})

  def get_open_orders(market), do: get_open_orders(market, 100)
  def get_open_orders(market, count) when is_number(market), do: make_request("GetOpenOrders", %{TradePairId: market, Count: count})
  def get_open_orders(market, count), do: make_request("GetOpenOrders", %{Market: market, Count: count})

  def get_trade_history(market), do: get_trade_history(market, 100)
  def get_trade_history(market, count), do: make_request("GetTradeHistory", %{TradePairId: market, Count: count})
  def get_trade_history(market, count), do: make_request("GetTradeHistory", %{Market: market, Count: count})

  # @spec get_transactions("Deposit" | "Withdraw") :: {:ok, [any]} | {:error, any}
  def get_transactions(type, count \\ 100), do: make_request("GetTransactions", %{Type: type, Count: count})

  # @spec submit_trade(number, "Buy" | "Sell", number, number) :: {:ok, [any]} | {:error, any}
  def submit_trade(market, type, rate, amount) when is_number(market) do 
    make_request("SubmitTrade", %{
      TradePairId: market,
      Type: type, 
      Rate: rate,
      Amount: amount
    })
  end

  # @spec submit_trade(String.t, "Buy" | "Sell", number, number) :: {:ok, [any]} | {:error, any}
  def submit_trade(market, type, rate, amount) do 
    make_request("SubmitTrade", %{
      Market: market,
      Type: type, 
      Rate: rate,
      Amount: amount
    })
  end

  @spec cancel_trade(number) :: {:ok, [number]} | {:error, any}
  def cancel_trade(order_id), do: make_request("CancelTrade", %{Type: "Trade", OrderId: order_id})

  # spec cancel_trade("All" | "Type" | "TradePair", number) :: {:ok, [number]} | {:error, any}
  @spec cancel_trade(String.t, number) :: {:ok, [number]} | {:error, any}
  def cancel_trade(type, pair_id), do: make_request("CancelTrade", %{Type: type, TradePairId: pair_id})

  @spec submit_tip(number, 2..100, number) :: {:ok, String.t} | {:error, any}
  def submit_tip(currency, users, amount) when is_number(currency) do  
    make_request("SubmitTip", %{
      CurrencyId: currency,
      ActiveUsers: users,
      Amount: amount
    })
  end

  @spec submit_tip(String.t, 2..100, number) :: {:ok, String.t} | {:error, any}
  def submit_tip(currency, users, amount) do  
    make_request("SubmitTip", %{
      Currency: currency,
      ActiveUsers: users,
      Amount: amount
    })
  end

  @spec submit_withdraw(number, String.t, String.t | number, number) :: {:ok, number} | {:error, any}
  def submit_withdraw(currency, address, payment_id, amount) when is_number(currency) do
    make_request("SubmitWithdraw", %{
      CurrencyId: currency,
      Address: address, 
      PaymentId: payment_id,
      Amount: amount
    })
  end

  @spec submit_withdraw(String.t, String.t, String.t | number, number) :: {:ok, number} | {:error, any}
  def submit_withdraw(currency, address, payment_id, amount) do
    make_request("SubmitWithdraw", %{
      Currency: currency,
      Address: address, 
      PaymentId: payment_id,
      Amount: amount
    })
  end

  @spec submit_transfer(number, String.t, number) :: {:ok, String.t} | {:error, any}
  def submit_transfer(currency, username, amount) when is_number(currency) do
    make_request("SubmitTransfer", %{
      CurrencyId: currency,
      Username: username,
      Amount: amount
    })
  end

  @spec submit_transfer(String.t, String.t, number) :: {:ok, String.t} | {:error, any}
  def submit_transfer(currency, username, amount) do
    make_request("SubmitTransfer", %{
      Currency: currency,
      Username: username,
      Amount: amount
    })
  end
end
