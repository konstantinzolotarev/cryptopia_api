# CryptopiaApi [![Hex pm](http://img.shields.io/hexpm/v/cryptopia_api.svg?style=flat)](https://hex.pm/packages/cryptopia_api) [![hex.pm downloads](https://img.shields.io/hexpm/dt/cryptopia_api.svg?style=flat)](https://hex.pm/packages/cryptopia_api)

Cryptopia Crypto currency exchange API.

[Public API](https://www.cryptopia.co.nz/Forum/Thread/255)
[Private API](https://www.cryptopia.co.nz/Forum/Thread/256)

## Installation

First add `cryptopia_api` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:cryptopia_api, "~> 0.1.0"}
  ]
end
```

and run `$ mix deps.get`. Then add `:cryptopia_api` to your applications list.

```elixir
def application do
  [applications: [:cryptopia_api]]
end
```

## Configuration

For Pulic API only no configuration is required.

But for Private API you have to configure application:

Add this lines to you application `config.exs`:

```elixir
use Mix.Config

config :cryptopia_api, api_key: "you-api-key-here"
config :cryptopia_api, secret_key: "your-secret-key-here"
```

## Usage

```elixir
iex(1)> CryptopiaApi.Public.get_market("ACC_BTC")
{:ok,
 %{AskPrice: 4.263e-5, BaseVolume: 0.68372883, BidPrice: 4.021e-5,
   BuyBaseVolume: 1.26308814, BuyVolume: 941758.73640983, Change: 35.97,
   Close: 4.007e-5, High: 4.809e-5, Label: "ACC/BTC", LastPrice: 4.007e-5,
   Low: 2.402e-5, Open: 2.947e-5, SellBaseVolume: 41.79914411,
   SellVolume: 67079.729386, TradePairId: 5331, Volume: 20217.2373583}}

iex(2)> CryptopiaApi.Public.get_market("ACC_BTC", 24)
{:ok,
 %{AskPrice: 4.263e-5, BaseVolume: 0.68367683, BidPrice: 4.022e-5,
   BuyBaseVolume: 1.28937411, BuyVolume: 942412.29131635, Change: 52.36,
   Close: 4.007e-5, High: 4.809e-5, Label: "ACC/BTC", LastPrice: 4.007e-5,
   Low: 2.402e-5, Open: 2.63e-5, SellBaseVolume: 41.79914411,
   SellVolume: 67079.729386, TradePairId: 5331, Volume: 20215.47258623}}
```

## License

    Copyright © 2017 Konstantin Zolotarev

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.
