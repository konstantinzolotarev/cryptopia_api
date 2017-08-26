defmodule CryptopiaApiTest do
  use ExUnit.Case
  doctest CryptopiaApi

  test "greets the world" do
    assert CryptopiaApi.hello() == :world
  end
end
