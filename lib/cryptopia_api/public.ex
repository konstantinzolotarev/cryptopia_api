defmodule CryptopiaApi.Public do

  import CryptopiaApi

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
  @spec get_markets(String.t) :: {:ok, [any]} | {:error, any}
  @spec get_markets(String.t, number) :: {:ok, [any]} | {:error, any}
  def get_markets, do: get_body("GetMarkets")
  def get_markets(market_or_hours), do: get_body("GetMarkets/" <> market_or_hours)
  def get_markets(market, hours), do: get_body("GetMarkets/#{market}/#{hours}")
  
  def get_market(market), do: get_body("GetMarket/#{market}")
  def get_market(market, hours), do: get_body("GetMarket/#{market}/#{hours}")

  def get_market_history(market), do: get_body("GetMarketHistory/#{market}")
  def get_market_history(market, hours), do: get_body("GetMarketHistory/#{market}/#{hours}")

  def get_market_orders(market), do: get_body("GetMarketOrders/#{market}")
  def get_market_orders(market, amount), do: get_body("GetMarketOrders/#{market}/#{amount}")
end
