defmodule CryptopiaApi.Public do

  import CryptopiaApi

  @moduledoc """
  Public API for [Cryptopia](https://www.cryptopia.co.nz/Forum/Thread/255) 
  """

  @doc """
  Load currencies form API

  ## Example
  ```elixir
  iex(2)> CryptopiaApi.Public.get_currencies
  {:ok,
    [%{Algorithm: "POS", DepositConfirmations: 20, Id: 331, IsTipEnabled: true,
      ListingStatus: "Active", MaxWithdraw: 2.0e9, MinBaseTrade: 2.0e-5,
      MinTip: 166.66666666, MinWithdraw: 2.0e4, Name: "1337", Status: "OK",
      StatusMessage: nil, Symbol: "1337", WithdrawFee: 0.01},
     %{Algorithm: "CryptoNight", DepositConfirmations: 20, Id: 391, ...},
     %{Algorithm: "Scrypt", DepositConfirmations: 200, ...},
     %{Algorithm: "Scrypt", ...}, %{...}, ...]}
  ```
  """
  @spec get_currencies() :: {:ok, [any]} | {:error, any}
  def get_currencies, do: get_body("GetCurrencies")

  @doc """
  Load trade pairs

  ## Example
  ```elixir
  iex(1)> CryptopiaApi.Public.get_trade_pairs
  {:ok,
    [%{BaseCurrency: "Tether", BaseSymbol: "USDT", Currency: "Bitcoin", Id: 4909,
      Label: "BTC/USDT", MaximumBaseTrade: 1.0e8, MaximumPrice: 1.0e8,
      MaximumTrade: 1.0e8, MinimumBaseTrade: 0.2, MinimumPrice: 1.0e-8,
      MinimumTrade: 1.0e-8, Status: "OK", StatusMessage: nil, Symbol: "BTC",
      TradeFee: 0.2},
     %{BaseCurrency: "NZed", BaseSymbol: "NZDT", Currency: "Bitcoin", Id: 5082,
       Label: "BTC/NZDT", MaximumBaseTrade: 1.0e8, MaximumPrice: 1.0e8,
       MaximumTrade: 1.0e8, MinimumBaseTrade: 0.2, MinimumPrice: 1.0e-8,
       MinimumTrade: 1.0e-8, Status: "OK", StatusMessage: nil, Symbol: "BTC",
       TradeFee: 0.2},
     %{BaseCurrency: "Litecoin", BaseSymbol: "LTC", Currency: "Lottocoin", ...},
     %{BaseCurrency: "Dogecoin", BaseSymbol: "DOGE", ...},
     %{BaseCurrency: "Bitcoin", ...}, %{...}, ...]}
  ```
  """
  @spec get_trade_pairs() :: {:ok, [any]} | {:error, any}
  def get_trade_pairs, do: get_body("GetTradePairs")

  @doc """
  Load list of markets from API

  ## Example
  ```elixir
  iex(4)> CryptopiaApi.Public.get_markets
  {:ok,
    [%{AskPrice: 3.4e-7, BaseVolume: 0.06151106, BidPrice: 3.3e-7,
      BuyBaseVolume: 1.20316179, BuyVolume: 24165298.27313356, Change: -5.71,
      Close: 3.3e-7, High: 3.8e-7, Label: "$$$/BTC", LastPrice: 3.3e-7,
      Low: 3.1e-7, Open: 3.5e-7, SellBaseVolume: 31490.81097327,
      SellVolume: 10782670.8537473, TradePairId: 1261, Volume: 176110.12588512},
     %{AskPrice: 4.2e-7, BaseVolume: 0.23717345, BidPrice: 4.1e-7, ...},
     %{AskPrice: 1.49999884, BaseVolume: 12.06876197, ...},
     %{AskPrice: 3.999e-5, ...}, %{...}, ...]}
  ```
  """
  @spec get_markets() :: {:ok, [any]} | {:error, any}
  @spec get_markets(String.t | number) :: {:ok, [any]} | {:error, any}
  @spec get_markets(String.t, number) :: {:ok, [any]} | {:error, any}
  def get_markets, do: get_body("GetMarkets")
  def get_markets(market_or_hours), do: get_body("GetMarkets/" <> market_or_hours)
  def get_markets(market, hours), do: get_body("GetMarkets/#{market}/#{hours}")
  
  @doc """
  Load market data for the specified trade pair

  ## Example
  ```elixir 
  iex(1)> CryptopiaApi.Public.get_market("ACC_BTC")
  {:ok,
    %{AskPrice: 4.263e-5, BaseVolume: 0.68372883, BidPrice: 4.021e-5,
      BuyBaseVolume: 1.26308814, BuyVolume: 941758.73640983, Change: 35.97,
      Close: 4.007e-5, High: 4.809e-5, Label: "ACC/BTC", LastPrice: 4.007e-5,
      Low: 2.402e-5, Open: 2.947e-5, SellBaseVolume: 41.79914411,
      SellVolume: 67079.729386, TradePairId: 5331, Volume: 20217.2373583}}
  ```

  Or with specified amount of hours
  ## Example
  ```elixir 
  iex(2)> CryptopiaApi.Public.get_market("ACC_BTC", 24)
  {:ok,
    %{AskPrice: 4.263e-5, BaseVolume: 0.68367683, BidPrice: 4.022e-5,
      BuyBaseVolume: 1.28937411, BuyVolume: 942412.29131635, Change: 52.36,
      Close: 4.007e-5, High: 4.809e-5, Label: "ACC/BTC", LastPrice: 4.007e-5,
      Low: 2.402e-5, Open: 2.63e-5, SellBaseVolume: 41.79914411,
      SellVolume: 67079.729386, TradePairId: 5331, Volume: 20215.47258623}}
  ```
  """
  @spec get_market(String.t) :: {:ok, map} | {:error, any}
  @spec get_market(String.t, number) :: {:ok, map} | {:error, any}
  def get_market(market), do: get_body("GetMarket/#{market}")
  def get_market(market, hours), do: get_body("GetMarket/#{market}/#{hours}")

  @doc """
  Load the market history data for the specified tarde pair

  ## Example
  ```elixir
  iex(4)> CryptopiaApi.Public.get_market_history("ACC_BTC")
  {:ok,
    [%{Amount: 52.07471966, Label: "ACC/BTC", Price: 4.007e-5,
      Timestamp: 1503907748, Total: 0.00208663, TradePairId: 5331, Type: "Sell"},
     %{Amount: 663.74065428, Label: "ACC/BTC", Price: 3.9e-5,
       Timestamp: 1503867219, ...},
     %{Amount: 114.49955333, Label: "ACC/BTC", Price: 3.898e-5, ...},
     %{Amount: 254.98840728, Label: "ACC/BTC", ...}, %{Amount: 8.33564879, ...},
     %{...}, ...]}
  ```

  Or with hours:

  ```elixir
  iex(5)> CryptopiaApi.Public.get_market_history("ACC_BTC", 1)
  {:ok,
    [%{Amount: 52.07471966, Label: "ACC/BTC", Price: 4.007e-5,
      Timestamp: 1503907748, Total: 0.00208663, TradePairId: 5331, Type: "Sell"}]}
  ```
  """
  @spec get_market_history(String.t) :: {:ok, [any]} | {:error, any}
  @spec get_market_history(String.t, number) :: {:ok, [any]} | {:error, any}
  def get_market_history(market), do: get_body("GetMarketHistory/#{market}")
  def get_market_history(market, hours), do: get_body("GetMarketHistory/#{market}/#{hours}")

  @doc """
  Load the open buy and sell orders for the specified tarde pair.

  ## Example
  ```elixir
  iex(7)> CryptopiaApi.Public.get_market_orders("ACC_BTC")
  {:ok,
    %{Buy: [%{Label: "ACC/BTC", Price: 4.03e-5, Total: 0.02628598,
      TradePairId: 5331, Volume: 652.25752705},
            %{Label: "ACC/BTC", Price: 8.3e-5, Total: 0.00587612, TradePairId: 5331,
              Volume: 70.79658512},
            %{Label: "ACC/BTC", Price: 8.362e-5, Total: 8.2432e-4, TradePairId: 5331,
              ...}, %{Label: "ACC/BTC", Price: 8.5e-5, Total: 0.0085, ...},
            %{Label: "ACC/BTC", Price: 9.0e-5, ...}, %{Label: "ACC/BTC", ...}, %{...},
            ...]}}
  ```

  Or same with hours
  ```elixir
  iex(8)> CryptopiaApi.Public.get_market_orders("ACC_BTC", 1)
  {:ok,
    %{Buy: [%{Label: "ACC/BTC", Price: 4.03e-5, Total: 0.02628598,
      TradePairId: 5331, Volume: 652.25752705}],
      Sell: [%{Label: "ACC/BTC", Price: 4.262e-5, Total: 0.00146507,
        TradePairId: 5331, Volume: 34.37512433}]}}
  ```
  """
  @spec get_market_orders(String.t) :: {:ok, [any]} | {:error, any}
  @spec get_market_orders(String.t, number) :: {:ok, [any]} | {:error, any}
  def get_market_orders(market), do: get_body("GetMarketOrders/#{market}")
  def get_market_orders(market, amount), do: get_body("GetMarketOrders/#{market}/#{amount}")
end
