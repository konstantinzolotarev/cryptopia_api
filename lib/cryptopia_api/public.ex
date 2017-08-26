defmodule CryptopiaApi.Public do

  import CryptopiaApi

  def get_currencies, do: get_body("GetCurrencies")
  
end
