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

  # defp make_request(method), do: make_request(method, "")
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
  @spec get_balance() :: {:ok, [term]} | {:error, term}
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
  @spec get_balance(number) :: {:ok, [term]} | {:error, term}
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
  @spec get_balance(String.t) :: {:ok, [term]} | {:error, term}
  def get_balance(currency), do: make_request("GetBalance", %{Currency: currency})

  @doc """
  Creates or returns a deposit address for the specified currency

  ## Example:
  ```elixir
  iex(1)> CryptopiaApi.Private.get_deposit_address(1)
  {:ok,
    %{Address: "1KUNsASBLTWfxStANiUEiTWktWvWhgUzqo", BaseAddress: nil,
      Currency: "BTC"}}
  ```
  """
  @spec get_deposit_address(number) :: {:ok, map} | {:error, term}
  def get_deposit_address(currencyId) when is_number(currencyId), do: make_request("GetDepositAddress", %{CurrencyId: currencyId})

  @doc """
  Creates or returns a deposit address for the specified currency

  ## Example:
  ```elixir
  iex(1)> CryptopiaApi.Private.get_deposit_address("BTC")
  {:ok,
    %{Address: "1KUNsASBLTWfxStANiUEiTWktWvWhgUzqo", BaseAddress: nil,
      Currency: "BTC"}}
  ```
  """
  @spec get_deposit_address(String.t) :: {:ok, map} | {:error, term}
  def get_deposit_address(currency), do: make_request("GetDepositAddress", %{Currency: currency})

  @doc """
  Returns a list of open orders for all tradepairs or specified tradepair

  ## Example
  ```elixir
  iex(10)> CryptopiaApi.Private.get_open_orders("ACC/BTC")
  {:ok,
    [%{Amount: 7.26568176, Market: "ACC/BTC", OrderId: 65930482, Rate: 1.023e-4,
      Remaining: 7.26568176, TimeStamp: "2017-08-25T21:33:25.3199485",
      Total: 7.4328e-4, TradePairId: 5331, Type: "Sell"}]}
  ```
  """
  @spec get_open_orders(String.t | number) :: {:ok, [term]} | {:error, term}
  def get_open_orders(market), do: get_open_orders(market, 100)

  @doc """
  Same as `get_open_orders/1` with additional 2nd parameter - amount of orders to return
  """
  @spec get_open_orders(String.t | number, number) :: {:ok, [term]} | {:error, term}
  def get_open_orders(market, count) when is_number(market), do: make_request("GetOpenOrders", %{TradePairId: market, Count: count})
  def get_open_orders(market, count), do: make_request("GetOpenOrders", %{Market: market, Count: count})

  @doc """
  Returns a list of trade history for all tradepairs or specified tradepair

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Private.get_trade_history("ACC/BTC")
  {:ok,
    [%{Amount: 723.30610462, Fee: 1.33e-6, Market: "NAMO/BTC", Rate: 9.2e-7,
      TimeStamp: "2017-08-28T12:14:31.8680187", Total: 6.6544e-4,
      TradeId: 15757416, TradePairId: 5405, Type: "Buy"},
     %{Amount: 500.0, Fee: 8.6e-7, Market: "NAMO/BTC", Rate: 8.6e-7,
       TimeStamp: "2017-08-28T12:12:09.4043842", Total: 4.3e-4, TradeId: 15757174,
       TradePairId: 5405, Type: "Sell"},
     %{Amount: 500.0, Fee: 6.2e-7, Market: "NAMO/BTC", Rate: 6.2e-7,
       TimeStamp: "2017-08-28T08:37:22.5063473", Total: 3.1e-4, TradeId: 15745534,
       TradePairId: 5405, Type: "Buy"},
     %{Amount: 7.26568176, Fee: 6.7e-7, Market: "ACC/BTC", Rate: 4.586e-5,
       TimeStamp: "2017-08-25T21:19:47.3708483", Total: 3.332e-4,
       TradeId: 15573801, TradePairId: 5331, Type: "Buy"},
     %{Amount: 93.07663016, Fee: 1.16e-6, Market: "OX/BTC", Rate: 6.24e-6,
       TimeStamp: "2017-08-25T20:31:38.4157247", Total: 5.808e-4,
       TradeId: 15571756, TradePairId: 5399, Type: "Buy"}]}
  ```
  """
  @spec get_trade_history(String.t | number) :: {:ok, [term]} | {:error, term}
  def get_trade_history(market), do: get_trade_history(market, 100)

  @doc """
  Returns a list of trade history for all tradepairs or specified tradepair with amount of records returned

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Private.get_trade_history("ACC/BTC", 1)
  {:ok,
    [%{Amount: 723.30610462, Fee: 1.33e-6, Market: "NAMO/BTC", Rate: 9.2e-7,
      TimeStamp: "2017-08-28T12:14:31.8680187", Total: 6.6544e-4,
      TradeId: 15757416, TradePairId: 5405, Type: "Buy"}]}
  ```
  """
  @spec get_trade_history(String.t | number, number) :: {:ok, [term]} | {:error, term}
  def get_trade_history(market, count) when is_number(market), do: make_request("GetTradeHistory", %{TradePairId: market, Count: count})
  def get_trade_history(market, count), do: make_request("GetTradeHistory", %{Market: market, Count: count})

  @doc """
  Load list of all deposit transactions.

  See `get_transactions/1` for more details
  """
  @spec get_deposit_transactions(number) :: {:ok, [term]} | {:error, term}
  def get_deposit_transactions(count \\ 100), do: get_transactions("Deposit", count)

  @doc """
  Load list of all withdraw transactions.

  See `get_transactions/1` for more details
  """
  @spec get_deposit_transactions(number) :: {:ok, [term]} | {:error, term}
  def get_withdraw_transactions(count \\ 100), do: get_transactions("Withdraw", count)

  @doc """
  Returns a list of transactions

  Type could be `"Deposit"` or `"Withdraw"`

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Private.get_transactions("Deposit")
  {:ok,
    [%{Address: nil, Amount: 0.002, Confirmations: 2, Currency: "BTC", Fee: 0.0,
      Id: 9515790, Status: "Confirmed", Timestamp: "2017-08-25T15:21:15",
      TxId: "1a6c1eddb4420eab6e847873104d21b0bc42f147737fa29f2f2b6598ccb5e619",
      Type: "Deposit"}]}
  ```
  """
  @spec get_transactions(String.t, number) :: {:ok, [term]} | {:error, term}
  def get_transactions(type, count \\ 100), do: make_request("GetTransactions", %{Type: type, Count: count})

  @doc """
  Submit a new Buy order

  Similar to `submit_trade/4` with type: `"Buy"`
  ## Example
  ```elixir
  iex(14)> CryptopiaApi.Private.submit_trade_buy(100, 0.00000250, 100)
  {:ok, %{FilledOrders: [], OrderId: 67556018}}
  ```
  """
  @spec submit_trade_buy(String.t | number, number, number) :: {:ok, map} | {:error, term}
  def submit_trade_buy(market, rate, amount), do: submit_trade(market, "Buy", rate, amount)

  @doc """
  Submit a new Sell order

  Similar to `submit_trade/4` with type: `"Sell"`
  ## Example
  ```elixir
  iex(14)> CryptopiaApi.Private.submit_trade_sell(100, 0.00000250, 100)
  {:ok, %{FilledOrders: [], OrderId: 67556018}}
  ```
  """
  @spec submit_trade_sell(String.t | number, number, number) :: {:ok, map} | {:error, term}
  def submit_trade_sell(market, rate, amount), do: submit_trade(market, "Sell", rate, amount)

  @doc """
  Submits a new trade order

  Type should be `"Buy"` or `"Sell"`

  ## Example
  ```elixir
  iex(14)> CryptopiaApi.Private.submit_trade(100, "Buy", 0.00000250, 100)
  {:ok, %{FilledOrders: [], OrderId: 67556018}}
  ```
  """
  @spec submit_trade(number, String.t, number, number) :: {:ok, map} | {:error, term}
  def submit_trade(market, type, rate, amount) when is_number(market) do 
    make_request("SubmitTrade", %{
      TradePairId: market,
      Type: type, 
      Rate: rate,
      Amount: amount
    })
  end

  @doc """
  Submits a transfer request

  Type should be `"Buy"` or `"Sell"`

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Private.submit_trade("ACC/BTC", "Buy", 0.00000250, 100)
  {:ok, %{FilledOrders: [], OrderId: 67731009}}
  ```
  """
  @spec submit_trade(String.t, String.t, number, number) :: {:ok, map} | {:error, term}
  def submit_trade(market, type, rate, amount) do 
    make_request("SubmitTrade", %{
      Market: market,
      Type: type, 
      Rate: rate,
      Amount: amount
    })
  end

  @doc """
  Cancels a single order

  ## Example
  ```elixir 
  iex(4)> CryptopiaApi.Private.cancel_trade(67731009)
  {:ok, [67731009]}
  ```
  """
  @spec cancel_trade(number) :: {:ok, [number]} | {:error, term}
  def cancel_trade(order_id), do: make_request("CancelTrade", %{Type: "Trade", OrderId: order_id})

  @doc """
  Cancels a single order, all orders for a tradepair or all open orders

  Type might be one of this: 
   - `"All"` - Cancel all open orders 
   - `"TradePair"` - Cancel order for given trade pair

  ```elixir
  iex(5)> CryptopiaApi.Private.cancel_trade("All", 100)
  {:ok, [65929994, 65930065, 65930124, 65930482, 67556018, 67538785]}

  iex(6)> CryptopiaApi.Private.cancel_trade("TradePair", 100)
  {:ok, [65929994, 65930065]}
  ```
  """
  @spec cancel_trade(String.t, number) :: {:ok, [number]} | {:error, term}
  def cancel_trade(type, pair_id), do: make_request("CancelTrade", %{Type: type, TradePairId: pair_id})

  @doc """
  Submits a tip to the Trollbox

  ## Example
  ```elixir
  iex(4)> CryptopiaApi.Private.submit_tip(1, 45, 0.00034500)
  {:ok, "You tipped 45 users 0.00034500 BTC each."}
  ```
  """
  @spec submit_tip(number, 2..100, number) :: {:ok, String.t} | {:error, term}
  def submit_tip(currency, users, amount) when is_number(currency) do  
    make_request("SubmitTip", %{
      CurrencyId: currency,
      ActiveUsers: users,
      Amount: amount
    })
  end

  @doc """
  Submits a tip to the Trollbox

  ## Example
  ```elixir
  iex(4)> CryptopiaApi.Private.submit_tip("BTC", 45, 0.00034500)
  {:ok, "You tipped 45 users 0.00034500 BTC each."}
  ```
  """
  @spec submit_tip(String.t, 2..100, number) :: {:ok, String.t} | {:error, term}
  def submit_tip(currency, users, amount) do  
    make_request("SubmitTip", %{
      Currency: currency,
      ActiveUsers: users,
      Amount: amount
    })
  end

  @doc """
  Submits a withdrawal request

  **Note** you have to enable this API in settings first

  ## Example
  ```elixir
  iex(6)> CryptopiaApi.Private.submit_withdraw(1, "1a6c1eddb4420eab6e847873104d21b0bc42f147737fa29f2f2b6598ccb5e619", "random-payment_id", 12)
  {:ok, 405667}
  ```
  """
  @spec submit_withdraw(number, String.t, String.t | number, number) :: {:ok, number} | {:error, term}
  def submit_withdraw(currency, address, payment_id, amount) when is_number(currency) do
    make_request("SubmitWithdraw", %{
      CurrencyId: currency,
      Address: address, 
      PaymentId: payment_id,
      Amount: amount
    })
  end

  @doc """
  Submits a withdrawal request

  **Note** you have to enable this API in settings first

  ## Example
  ```elixir
  iex(6)> CryptopiaApi.Private.submit_withdraw("BTC", "1a6c1eddb4420eab6e847873104d21b0bc42f147737fa29f2f2b6598ccb5e619", "random-payment_id", 12)
  {:ok, 405667}
  ```
  """
  @spec submit_withdraw(String.t, String.t, String.t | number, number) :: {:ok, number} | {:error, term}
  def submit_withdraw(currency, address, payment_id, amount) do
    make_request("SubmitWithdraw", %{
      Currency: currency,
      Address: address, 
      PaymentId: payment_id,
      Amount: amount
    })
  end

  @doc """
  Submits a transfer request

  ## Example
  ```elixir
  iex(6)> CryptopiaApi.Private.submit_transfer(1, "kosss", 100)
  {:ok, "Successfully transfered 100 BTC to Kosss"}
  ```
  """
  @spec submit_transfer(number, String.t, number) :: {:ok, String.t} | {:error, term}
  def submit_transfer(currency, username, amount) when is_number(currency) do
    make_request("SubmitTransfer", %{
      CurrencyId: currency,
      Username: username,
      Amount: amount
    })
  end

  @doc """
  Submits a transfer request

  ## Example
  ```elixir
  iex(6)> CryptopiaApi.Private.submit_transfer("BTC", "kosss", 100)
  {:ok, "Successfully transfered 100 BTC to Kosss"}
  ```
  """
  @spec submit_transfer(String.t, String.t, number) :: {:ok, String.t} | {:error, term}
  def submit_transfer(currency, username, amount) do
    make_request("SubmitTransfer", %{
      Currency: currency,
      Username: username,
      Amount: amount
    })
  end
end
